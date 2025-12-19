// http://adventofcode.com/2025/day/6
package main

import (
	"bufio"
	"fmt"
	"os"
	"slices"
	"strconv"
	"strings"
)

func readInput() string {
	scanner := bufio.NewScanner(os.Stdin)
	var lines []string

	for scanner.Scan() {
		line := scanner.Text()
		lines = append(lines, fmt.Sprintf("%v\n", line))
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("Error:", err)
	}

	return strings.Trim(strings.Join(lines, ""), "\n")
}

func main() {
	input := readInput()
	fmt.Printf("Part 1: %v\n", part1(input))
	fmt.Printf("Part 2: %v\n", part2(input))
}

func solve(problems *[][]string) string {
	// Now solve
	var solutions = []int{}
	totalSum := 0
	for _, p := range *problems {
		op := p[len(p)-1]
		s := 0
		if op == "*" {
			s = 1
		}

		for _, ns := range p[0 : len(p)-1] {
			if ns == "" {
				continue
			}

			n, e := strconv.Atoi(ns)
			if e != nil {
				panic(fmt.Sprintf("Error converting \"%v\": %s", ns, e))
			}

			if op == "+" {
				s += n
			}

			if op == "*" {
				s *= n
			}
		}

		solutions = append(solutions, s)
		totalSum += s
	}

	return strconv.Itoa(totalSum)
}

func part1(input string) string {
	// Read problems
	var problems = [][]string{}
	for _, s := range strings.Split(input, "\n") {
		for ri, r := range strings.FieldsFunc(s, func(r rune) bool { return r == ' ' }) {
			if len(problems) == ri {
				problems = append(problems, []string{})
			}

			problems[ri] = append(problems[ri], r)
		}
	}

	return solve(&problems)
}

func part2(input string) string {
	// Scan to find space-only columns
	// Set by https://www.willem.dev/articles/sets-in-golang/
	spaceIndexMap := map[int]bool{}
	var rows = strings.Split(input, "\n")
	for ri, r := range rows {
		for si, s := range r {
			spaceIndexMap[si] = s == ' ' && (spaceIndexMap[si] || ri == 0)
		}
	}

	spaceIndices := []int{}
	for idx, y := range spaceIndexMap {
		if y {
			spaceIndices = append(spaceIndices, idx)
		}
	}
	slices.Sort(spaceIndices)

	columns := [][]string{}
	for ri, r := range rows {
		for i, si := range spaceIndices {
			if ri == 0 {
				columns = append(columns, []string{})

				if i == len(spaceIndices)-1 {
					columns = append(columns, []string{})
				}
			}

			if i == 0 {
				columns[i] = append(columns[i], r[0:si])
			} else {
				psi := spaceIndices[i-1]
				columns[i] = append(columns[i], r[psi+1:si])
			}

			if i == len(spaceIndices)-1 {
				columns[i+1] = append(columns[i+1], r[si+1:])
			}
		}
	}

	var problems = [][]string{}
	for _, c := range columns {
		numbers := []string{}
		for i := 0; i < len(c[0]); i++ {
			for si, s := range c {
				if si == len(c)-1 {
					continue
				}

				if len(numbers) == si {
					numbers = append(numbers, "")
				}

				numbers[i] = strings.Trim(fmt.Sprintf("%s%c", numbers[i], s[i]), " ")
			}
		}

		numbers = append(numbers, strings.Trim(c[len(c)-1], " "))
		problems = append(problems, numbers)
	}

	return solve(&problems)
}
