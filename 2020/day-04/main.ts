// http://adventofcode.com/2020/day/4
const readFromStandardInput = new Promise<String>((r) => {
    process.stdin.on("data", d => r(d.toString()))
})

function notEmpty<TValue>(value: TValue | null | undefined): value is TValue {
    return value !== null && value !== undefined;
}

type Height = { n: number, u: "cm" | "in" | null }
type Passport = {
    byr: number,    // Birth year
    iyr: number     // Issue year
    eyr: number,    // Expiration year
    hgt: Height,    // Height
    hcl: string,    // Hex color
    ecl: string,    // Eye color
    pid: string,    // Passport ID
    cid: string,    // Country ID
    raw: string     // for debug
}

const optionalParse = <T>(v: string | undefined, parse: (s: string) => T) => {
    if (v) {
        return parse(v);
    }
}

const parseHeight = (s: string): Height | null => {
    // First try to match 183cm, 71in
    const match = s.match(/(?<n>\d+)(?<u>in|cm)/);
    if (match?.groups) {
        const n = Number(match.groups["n"]);
        const u = match.groups["u"];

        if (u === "cm" || u === "in") {
            return { n, u };        
        }
    }

    // Next try to match naked numbers
    if (s.match(/\d+/)) {
        return { n: Number(s), u: null };
    }

    console.log(`${s} failed to parseHeight`)
    return null;
}

const parsePassport = (s: string): Partial<Passport> | null => {
    const matches = s.match(/\S+:\S+/g);
    if (matches === null) {
        return null;
    }

    const raw = Object.fromEntries(matches.map((s) => s.split(":")));

    return {
        byr: optionalParse(raw.byr, Number),
        iyr: optionalParse(raw.iyr, Number),
        eyr: optionalParse(raw.eyr, Number),
        hgt: optionalParse(raw.hgt, parseHeight) || undefined,
        hcl: raw.hcl,
        ecl: raw.ecl,
        pid: raw.pid,
        cid: raw.cid,
        raw: s,
    }
}

const simpleValidatePassport = (p: Partial<Passport>): boolean => {
    const keys: Array<keyof Passport> = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"];
    const isValid = keys.every((k) => p[k]);

    return isValid;
}

const complexValidatePassport = ({ byr, iyr, eyr, hgt, hcl, ecl, pid, cid, raw }: Passport): boolean => {
    // byr (Birth Year) - four digits; at least 1920 and at most 2002.
    const byrValid = (byr >= 1920 && byr <= 2002);
        
    // iyr (Issue Year) - four digits; at least 2010 and at most 2020.
    const iyrValid = (iyr >= 2010 && iyr <= 2020);
        
    // eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
    const eyrValid = (eyr >= 2020 && eyr <= 2030);

    // hgt (Height) - a number followed by either cm or in:
    // If cm, the number must be at least 150 and at most 193.
    // If in, the number must be at least 59 and at most 76.
    const hgtValidation = {
        "cm": (n: number) => (n >= 150 && n <= 193),
        "in": (n: number) => (n >= 59 && n <= 76),
        "default": (n: number) => false
    };
    const hgtValid = hgtValidation[hgt.u ?? "default"](hgt.n);
    
    // hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
    const hclValid = hcl.match(/#[a-f0-9]{6}/) ? true : false

    // ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
    const eclValid = ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].includes(ecl)

    // pid (Passport ID) - a nine-digit number, including leading zeroes.
    const pidValid = pid.match(/^\d{9}$/) ? true : false

    // cid (Country ID) - ignored, missing or not.
    const cidValid = true;

    type V = { byrValid: boolean, iyrValid: boolean, eyrValid: boolean, hgtValid: boolean, hclValid: boolean, eclValid: boolean, pidValid: boolean, cidValid: boolean };
    const validation = { byrValid, iyrValid, eyrValid, hgtValid, hclValid, eclValid, pidValid, cidValid };
    const isValid = Object.keys(validation).every((key) => validation[key as keyof(V)])

    if (!isValid) {
        console.log(raw, "not valid bc", validation)
    }

    return isValid;
}

const main = async () => {
    const input = await readFromStandardInput
    
    const entries = input.split("\n\n")
    const passports = entries.map(parsePassport).filter(notEmpty);
    const validPassports = passports.filter(simpleValidatePassport);

    console.log(`Pt 1: ${validPassports.length}`);

    const fullValidPassports = validPassports as Array<Passport> // 🙈
    const reallyValidPassports = (fullValidPassports).filter(complexValidatePassport);

    // 128 too high
    console.log(`Pt 2: ${reallyValidPassports.length}`);
}

main()
