/*
Navicat MySQL Data Transfer

Source Server         : HiChe
Source Server Version : 50717
Source Host           : localhost:3306
Source Database       : dangjian

Target Server Type    : MYSQL
Target Server Version : 50717
File Encoding         : 65001

Date: 2019-06-22 11:08:55
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for t_cms_article_category
-- ----------------------------
DROP TABLE IF EXISTS `t_cms_article_category`;
CREATE TABLE `t_cms_article_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '标识',
  `parent_id` int(11) DEFAULT NULL COMMENT '父节点',
  `lft` int(11) DEFAULT NULL,
  `rgt` int(11) DEFAULT NULL,
  `name` varchar(50) NOT NULL COMMENT '名称',
  `is_show` tinyint(1) NOT NULL COMMENT '是否显示.0表示不显示,1表示显示',
  `sort_num` int(11) NOT NULL COMMENT '排序值',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_user` int(11) DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_user` int(11) DEFAULT NULL COMMENT '修改者',
  `update_time` datetime DEFAULT NULL COMMENT '修改时间',
  `is_deleted` int(2) DEFAULT NULL COMMENT '逻辑删除标识。仅且仅有0和1两个值，1表示已经被逻辑删除，0表示正常可用。',
  `status` int(2) DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COMMENT='新闻分类';

-- ----------------------------
-- Records of t_cms_article_category
-- ----------------------------
INSERT INTO `t_cms_article_category` VALUES ('1', '0', '1', '10', '废弃分类1', '1', '2', null, '1', '2019-06-22 10:47:04', '1', '2019-06-22 10:47:04', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('2', '0', '11', '20', '废弃分类2', '1', '2', null, '1', '2019-06-22 10:47:10', '1', '2019-06-22 10:47:10', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('3', '0', '21', '30', '废弃分类3', '1', '2', null, '1', '2019-06-22 10:47:12', '1', '2019-06-22 10:47:12', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('4', '0', '31', '46', '废弃分类4', '1', '2', null, '1', '2019-06-22 10:47:16', '1', '2019-06-22 10:47:16', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('5', '1', '2', '3', '废弃分类1-1', '1', '2', null, '1', '2019-06-22 10:47:23', '1', '2019-06-22 10:47:23', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('6', '1', '4', '5', '废弃分类1-2', '1', '2', null, '1', '2019-06-22 10:47:26', '1', '2019-06-22 10:47:26', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('7', '1', '6', '7', '废弃分类1-3', '1', '2', null, '1', '2019-06-22 10:47:31', '1', '2019-06-22 10:47:31', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('8', '1', '8', '9', '废弃分类1-4', '1', '2', null, '1', '2019-06-22 10:47:34', '1', '2019-06-22 10:47:34', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('9', '2', '12', '13', '废弃分类2-1', '1', '2', null, '1', '2019-06-22 10:48:00', '1', '2019-06-22 10:48:00', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('10', '2', '14', '15', '废弃分类2-2', '1', '2', null, '1', '2019-06-22 10:48:03', '1', '2019-06-22 10:48:03', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('11', '2', '16', '17', '废弃分类2-3', '1', '2', null, '1', '2019-06-22 10:48:07', '1', '2019-06-22 10:48:07', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('12', '2', '18', '19', '废弃分类2-4', '1', '2', null, '1', '2019-06-22 10:48:10', '1', '2019-06-22 10:48:10', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('13', '3', '22', '23', '废弃分类3-1', '1', '2', null, '1', '2019-06-22 10:48:18', '1', '2019-06-22 10:48:18', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('14', '3', '24', '25', '废弃分类3-2', '1', '2', null, '1', '2019-06-22 10:48:23', '1', '2019-06-22 10:48:23', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('15', '3', '26', '27', '废弃分类3-3', '1', '2', null, '1', '2019-06-22 10:48:26', '1', '2019-06-22 10:48:26', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('16', '3', '28', '29', '废弃分类3-4', '1', '2', null, '1', '2019-06-22 10:48:31', '1', '2019-06-22 10:48:31', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('17', '4', '32', '39', '废弃分类4-1', '1', '2', null, '1', '2019-06-22 10:48:39', '1', '2019-06-22 10:48:39', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('18', '4', '40', '41', '废弃分类4-2', '1', '2', null, '1', '2019-06-22 10:48:43', '1', '2019-06-22 10:48:43', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('19', '4', '42', '43', '废弃分类4-3', '1', '2', null, '1', '2019-06-22 10:48:46', '1', '2019-06-22 10:48:46', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('20', '4', '44', '45', '废弃分类4-4', '1', '2', null, '1', '2019-06-22 10:48:51', '1', '2019-06-22 10:48:51', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('21', '17', '33', '38', '废弃分类4-1-1', '1', '2', null, '1', '2019-06-22 11:07:34', '1', '2019-06-22 11:07:34', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('22', '21', '34', '37', '废弃分类4-1-1-1', '1', '2', null, '1', '2019-06-22 11:07:48', '1', '2019-06-22 11:07:48', '0', '1');
INSERT INTO `t_cms_article_category` VALUES ('23', '22', '35', '36', '废弃分类4-1-1-1-1', '1', '2', null, '1', '2019-06-22 11:07:56', '1', '2019-06-22 11:07:56', '0', '1');
