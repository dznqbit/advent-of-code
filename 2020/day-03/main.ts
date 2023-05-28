// http://adventofcode.com/2020/day/03
const readFromStandardInput = new Promise<String>((r) => {
    process.stdin.on("data", d => r(d.toString()))
})

type Slope = { right: number, down: number }
type ForestPlot = "#" | ".";
type Forest = Array<Array<ForestPlot>>;
type Coordinates = { x: number, y: number }

const infiniteForest = (forest: Forest, { x, y }: Coordinates) => {
    return forest[y][x % forest[0].length];
}

const countTrees = (forest: Forest, slope: Slope) => {
    let treeCount = 0;
    const position: Coordinates = { x: 0, y: 0 };

    while (position.y < forest.length - 1) {
        position.x += slope.right;
        position.y += slope.down;

        if (infiniteForest(forest, position) === '#') {
            treeCount += 1;
        }
    }

    return treeCount;
}

const main = async () => {
    const input = await readFromStandardInput
    const forest = input.split("\n").map((s) => s.split('')) as Forest; // Naughty...
    const treeCount = countTrees(forest, { right: 3, down: 1 });
    console.log(`Pt 1: ${treeCount}`);

    const pt2TreeCounts = [
        countTrees(forest, { right: 1, down: 1 }),
        countTrees(forest, { right: 3, down: 1 }),
        countTrees(forest, { right: 5, down: 1 }),
        countTrees(forest, { right: 7, down: 1 }),
        countTrees(forest, { right: 1, down: 2 })
    ];
    const pt2TreeCount = pt2TreeCounts.reduce((a,n) => a * n, 1);
    console.log(`Pt 2: ${pt2TreeCount}`);
}

main()
