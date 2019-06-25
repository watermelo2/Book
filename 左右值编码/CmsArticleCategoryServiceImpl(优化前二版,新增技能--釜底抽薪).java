package org.springblossom.cms.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springblossom.cms.entity.CmsArticleCategory;
import org.springblossom.cms.mapper.CmsArticleCategoryMapper;
import org.springblossom.cms.service.ICmsArticleCategoryService;
import org.springblossom.cms.tool.ArrayUtil;
import org.springblossom.cms.tool.ObjectUtil;
import org.springblossom.cms.vo.CmsArticleCategoryVO;
import org.springblossom.core.mp.base.BaseServiceImpl;
import org.springblossom.core.tool.node.ForestNodeMerger;
import org.springblossom.core.tool.utils.BeanUtil;
import org.springblossom.system.feign.IDictClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.validation.constraints.NotEmpty;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 新闻分类 服务实现类
 *
 * @author ztx
 * @since 2019-04-26
 */
@Data
@Service
@EqualsAndHashCode(callSuper = false)
public class CmsArticleCategoryServiceImpl extends BaseServiceImpl<CmsArticleCategoryMapper, CmsArticleCategory> implements ICmsArticleCategoryService {

	@Override
	public IPage<CmsArticleCategory> selectCmsCategoryPage(IPage<CmsArticleCategory> page, CmsArticleCategory cmsCategory) {
		List<CmsArticleCategory> articleCategorys = baseMapper.selectCmsCategoryPage(page, cmsCategory);
		return page.setRecords(articleCategorys);
	}

	@Override
	public IPage<CmsArticleCategoryVO> tree(IPage<CmsArticleCategoryVO> page, CmsArticleCategory cmsCategory) {
		List<CmsArticleCategoryVO> articleCategoryVos = baseMapper.tree(page, cmsCategory);
		articleCategoryVos.forEach(x -> {
			Integer parentId = x.getParentId();
			if (!ObjectUtil.isEmpty(parentId)) {
				CmsArticleCategory parent = getById(parentId);
				CmsArticleCategoryVO parentVo = BeanUtil.copy(parent, CmsArticleCategoryVO.class);
				x.setParent(parentVo);
			}
		});
		return page.setRecords(ForestNodeMerger.merge(articleCategoryVos));
	}

	@Override
	public boolean save(CmsArticleCategory entity) {
		CmsArticleCategory.init(entity);

		Integer parentId = entity.getParentId();
		Integer currPosition;
		if (!ObjectUtil.isEmpty(parentId)) {
			CmsArticleCategory parentNode = super.getById(parentId);
			int parentRgt = parentNode.getRgt();
			currPosition = parentRgt;

			// 当前节点的父节点的后置节点往后排
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" rgt=rgt+2 ").ge(true, "rgt", parentRgt));
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" lft=lft+2 ").ge(true, "lft", parentRgt));
		} else {
			// 根节点往右置外围编码后面排
			currPosition = rightter() + 1;
		}

		entity.setLft(currPosition);
		entity.setRgt(currPosition + 1);

		return super.save(entity);
	}

	@Override
	public boolean updateById(CmsArticleCategory entity) {
		CmsArticleCategory.init(entity);

		CmsArticleCategory oldInfo = getById(entity.getId());
		Integer oldParentId = oldInfo.getParentId();
		Integer currParentId = entity.getParentId();
		if (!ObjectUtil.equals(oldParentId, currParentId)) {
			// 需要改的才改
			Integer currParentRgt;
			if (!ObjectUtil.isEmpty(currParentId)) {
				// 给currentParent(当前节点的父节点)编码值扩容

				Integer oldLft = oldInfo.getLft();
				Integer oldRgt = oldInfo.getRgt();
				// 节点跨度(代表包括当前节点在内有多少个节点)
				int span = oldRgt - oldLft + 1;

				CmsArticleCategory currParentInfo = getById(currParentId);
				currParentRgt = currParentInfo.getRgt();

				super.update(Wrappers.<CmsArticleCategory>update().setSql(" lft=lft+" + span).ge(true, "lft", currParentRgt));
				super.update(Wrappers.<CmsArticleCategory>update().setSql(" rgt=rgt+" + span).ge(true, "rgt", currParentRgt));
			} else {
				// 根节点往右置外围编码后面排
				currParentRgt = rightter() + 1;
			}

			oldInfo = getById(entity.getId());
			Integer oldLft = oldInfo.getLft();
			Integer oldRgt = oldInfo.getRgt();

			int span = oldRgt - oldLft + 1;
			int offset = currParentRgt - oldLft;

			// 将当前节点之前的子节点(们)移到当前节点的父节点下
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" lft=lft+" + offset + ",rgt=rgt+" + offset).between(true, "lft", oldLft, oldRgt));

			// 后置节点(之后新增的所有节点,这时已经不包含当前节点的子节点了,因为已经移动到当前节点的父节点下了)前移
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" lft=lft-" + span).ge(true, "lft", oldRgt));
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" rgt=rgt-" + span).ge(true, "rgt", oldRgt));
		}

		return super.updateById(entity);
	}

	@Override
	public boolean deleteLogic(@NotEmpty @NotEmpty List<Integer> ids) {
		for (Integer it : ids) {
			CmsArticleCategory deleteInfo = super.getOne(Wrappers.<CmsArticleCategory>lambdaUpdate().eq(CmsArticleCategory::getId, it));
			Integer lft = deleteInfo.getLft();
			Integer rgt = deleteInfo.getRgt();

			// 删子节点数据
			List<CmsArticleCategory> removeChildren = list(Wrappers.<CmsArticleCategory>lambdaQuery().select(CmsArticleCategory::getId).ge(true, CmsArticleCategory::getLft, lft).le(true, CmsArticleCategory::getRgt, rgt));
			if (ArrayUtil.isNotEmpty(removeChildren)) {
				super.deleteLogic(removeChildren.stream().map(CmsArticleCategory::getId).collect(Collectors.toList()));
			}

			// 节点跨度
			int span = rgt - lft + 1;
			// 后置节点前移(此时子节点已经没了)
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" lft=lft-" + span).gt(true, "lft", rgt));
			super.update(Wrappers.<CmsArticleCategory>update().setSql(" rgt=rgt-" + span).gt(true, "rgt", rgt));
		}
		return true;
	}

	@Override
	public int rightter() {
		Integer queryResult = baseMapper.selectMaxOfRgt();
		return ObjectUtil.isNull(queryResult) ? 0 : queryResult;
	}

	@Override
	public List<CmsArticleCategoryVO> tree(Integer id) {
		CmsArticleCategory categoryInfo = getById(id);
		List<CmsArticleCategory> queryResult = list(Wrappers.<CmsArticleCategory>lambdaQuery().ge(true, CmsArticleCategory::getLft, categoryInfo.getLft()).le(true, CmsArticleCategory::getRgt, categoryInfo.getRgt()));

		List<CmsArticleCategoryVO> result = new ArrayList<>(queryResult.size());
		for (CmsArticleCategory it : queryResult) {
			CmsArticleCategoryVO vo = BeanUtil.copy(it, CmsArticleCategoryVO.class);
			result.add(vo);
		}

		result = ForestNodeMerger.merge(result);
		return result;
	}

	/**
	 * LOOK 后置为lft、rgt编码值移动单位不知道有没有问题.. 而且并没有将外圈的lft、rgt编码值对应调整,所以暂时不建议使用.
	 *
	 * <p>
	 * TODO 该实现没有将符合条件的节点的lft、rgt编码值做对应调整(缩小编码值).原因一个在于编码复杂度较大,另一个在于
	 * 实现这个效果基本上整张表的数据都操作了(优化这两个编码值导致的代价非常大).
	 * </p>
	 *
	 * @param ids
	 * @return
	 */
	@Override
	public boolean pullOut(List<Integer> ids) {
		for (Integer it : ids) {
			CmsArticleCategory removeNode = getById(it);
			Integer preParentId = removeNode.getParentId();
			Integer preLft = removeNode.getLft();

			super.update(Wrappers.<CmsArticleCategory>update().setSql("parent_id=" + preParentId).eq(true, "parent_id", it));
			super.update(Wrappers.<CmsArticleCategory>update().setSql("lft=lft-1,rgt=rgt-1").gt(true, "lft", preLft));
		}
		boolean result = super.deleteLogic(ids);
		return result;
	}

	@Autowired
	private IDictClient dictClient;
}
