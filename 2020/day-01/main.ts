// http://adventofcode.com/2020/day/1
const readFromStandardInput = new Promise<String>((r) => {
    process.stdin.on("data", d => r(d.toString()))
})

const findPairThatSums = (list: Array<number>, target: number) => {
    for (const i of [...list.keys()]) {
        const n = list[i]
        const sublist = list.slice(i + 1)
        const b = sublist.find((sn) => (sn + n) === target)

        if (b) {
            return [n, b]
        }
    }
}

const findTrioThatSums = (list: Array<number>, target: number) => {
    for (const i of [...list.keys()]) {
        const n = list[i]
        const r = findPairThatSums(list.slice(i + 1), 2020 - n)

        if (r) {
            return [n, ...r];
        }
    }
}

const main = async () => {
    const input = await readFromStandardInput
    const numbers = input.split("\n").map(Number)
    
    const pair = findPairThatSums(numbers, 2020)
    if (!pair) {
        console.log("Could not find pair :(")
        return;
    }

    const [a, b] = pair;
    const pt1Result = a * b;
    console.log(`Pt 1: ${pt1Result}`)

    const trio = findTrioThatSums(numbers, 2020)
    if (!trio) {
        console.log("Could not find trio :(")
        return;
    }

    const [ta, tb, tc] = trio;
    const pt2Result = ta * tb * tc;
    console.log(`Pt 2: ${pt2Result}`)
}

main()
