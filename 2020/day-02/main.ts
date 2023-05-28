// http://adventofcode.com/2020/day/2
const readFromStandardInput = new Promise<String>((r) => {
    process.stdin.on("data", d => r(d.toString()))
})

function notEmpty<TValue>(value: TValue | null | undefined): value is TValue {
    return value !== null && value !== undefined;
}

type PolicyEntry = {
    c: String, 
    min: number,
    max: number, 
    password: String
}

const parsePolicyEntry = (s: String): PolicyEntry | null => {
    const match = s.match(/(?<min>\d+)-(?<max>\d+) (?<c>\w)\: (?<password>\w+)/)

    if (match?.groups) {
        const min = Number(match.groups["min"]),
        max = Number(match.groups["max"]),
        c = match.groups["c"],
        password = match.groups["password"];

        return { c, min, max, password };
    }

    return null;
}

const checkPasswordAgainstPolicy = ({ password, c, min, max }: PolicyEntry) => {
    const numOccurrences = (password.match(new RegExp(`${c}`, 'g')) || []).length;
    return (numOccurrences >= min && numOccurrences <= max);
}

const checkPasswordAgainstPt2Policy = ({ password, c, min, max }: PolicyEntry) => {
    const c1 = password[min - 1];
    const c2 = password[max - 1];
    return (c === c1 && c !== c2) || (c === c2 && c !== c1);
}

const main = async () => {
    const input = await readFromStandardInput
    const rawPolicyEntries = input.split("\n").map(parsePolicyEntry);
    const policyEntries = rawPolicyEntries.filter(notEmpty);

    if (rawPolicyEntries.length != policyEntries.length) {
        console.log("Could not parse PolicyEntries");
        return;
    }

    const passingPolicyEntries = policyEntries.filter(checkPasswordAgainstPolicy);
    console.log(`Pt 1: ${passingPolicyEntries.length}`)

    const pt2PassingPolicyEntries = policyEntries.filter(checkPasswordAgainstPt2Policy);
    console.log(`Pt 2: ${pt2PassingPolicyEntries.length}`)
}

main()
