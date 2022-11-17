/**
 * 思路:
 * 1. (关键)为每个<code>inputA</code>中的元素提前计算出<code>inputB</code>中有可能成为因子的所有排列组合(O(N)),记作"S"
 * 2. 为每个<code>inputA</code>中的元素("A")遍历对应的"S",遍历一个元素就减去对应的值(减去后的值为"X")
 * 3. 如果"X=0"则表示该遍历路径上的数为凑成"A"的因子
 * 4. 如果"X"在"S"的中(S[X])没有对应的数组(数组为空),则表示该遍历路径凑不出"A"
 *
 * PS: 它和普通的穷举法区别在于它提前计算了可能成为因子的排列组合,能够非常快的知道哪些因子组合是不可能凑成<code>inputA</code>中的数
 */
function cal() {
  console.clear()

  let inputA = [21.04, 15.08, 2.52]
  let inputB = [3.36, 3.36, 2.52, 1.68, 1.68, 1.40, 1.40, 1.40, 0.84, 0.84,
    0.84, 0.84, 0.84, 0.84, 0.84, 0.80, 0.80, 0.80, 0.56, 0.56, 0.56, 0.56,
    0.56, 0.56, 0.56, 0.40, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28,
    0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28,
    0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28, 0.28,
    0.28]

  let sortedA = inputA.map(n => Math.round(n * 100)).sort(function (a, b) {
    return a - b;
  });

  let mapB = new Map();
  inputB.forEach(n => mapB.set(n, mapB.get(n) ? mapB.get(n) + 1 : 1));

  let sortedDistinctB = [...mapB.keys()].sort(function (a, b) {
    return a - b;
  });

  let repeatTimesB = sortedDistinctB.map(n => mapB.get(n));

  sortedDistinctB = sortedDistinctB.map(n => Math.round(100 * parseFloat(n)))

  // console.log(sortedA, sortedDistinctB, repeatTimesB);

  /**
   * @param target 需要求的数
   * @returns 一个二维数组,包含所有能计算出结果为<code>target</code>的组合
   */
  function solve(target) {
    let result = Array.from(Array(target + 1)).map(n => new Set())
    result[0].add(0);

    /*
      (重要)数据形式表现如下

      数据源(inputB): [2,2,4,6,7,8,8,10]
      target: 20

      [[0],[],[2],[],[2,4],[],[6],[7],[4],[],[10],[],[],[],[],[],[8],[],[],[],[],[],[],[],[8],[]]

      解释: 外层数组的下标(i)本身表示为"inputA"中可能出现的数(也可以认为'合'),我们暂且把它称之为"X",下标对应的数组值表示"数据源"中可以凑成"X"的所有集
     */
    for (let i = 0; i < sortedDistinctB.length; i++) {
      for (let j = 1; j <= repeatTimesB[i]; j++) {
        for (let k = target - sortedDistinctB[i]; k >= 0; k--) {
          if (result[k].size !== 0) {
            result[k + sortedDistinctB[i]].add(sortedDistinctB[i]);
          }
        }
      }
    }

    result = result.map(s => Array.from(s).reverse());

    // console.log(result);

    return result;
  }

  function sum() {
    let s = 0;
    for (let i = 0; i < sortedDistinctB.length; i++) {
      s += sortedDistinctB[i] * repeatTimesB[i];
    }
    return s;
  }

  function dfs(i) {
    if (i === sortedA.length) {
      throw new Error();
    }

    let dp = solve(sortedA[i]);
    // console.log(sortedA[i], dp);

    let ans = []
    let num = 0

    function allSolution(r, p) {
      if (num > 10) {
        return
      }

      if (r === 0) {
        num++;

        // console.log(sortedA[i], sum(), repeatTimesB, num, ans);

        try {
          dfs(i + 1);
        } catch (e) {
          console.log(`<li>${sortedA[i] / 100} = ${ans.map(n => n / 100).reduce(
              (a, b) => a + '+' + b, '').substring(1)}</li>`)
          throw e;
        }

        return;
      }
      let x = 0;

      dp[r].forEach(v => {
        if (v > p) {
          return;
        }
        x++;
        if (repeatTimesB[sortedDistinctB.indexOf(v)] === 0) {
          return;
        }
        repeatTimesB[sortedDistinctB.indexOf(v)]--;
        ans.push(v);
        allSolution(r - v, v);
        ans.pop(v);
        repeatTimesB[sortedDistinctB.indexOf(v)]++;
      })
    }

    allSolution(sortedA[i], 1e9);
  }

  try {
    dfs(0)
    console.log('没搜到结果（代码限制了搜索范围，不代表真的没解）')
  } catch (e) {

  }

}