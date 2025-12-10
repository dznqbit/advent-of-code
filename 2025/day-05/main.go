// http://adventofcode.com/2025/day/05
package main

import (
	"bufio"
	"fmt"
	"os"
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

	inputSections := strings.Split(input, "\n\n")

	freshIngredientRanges := [][]int{}
	for _, line := range strings.Split(inputSections[0], "\n") {
		ri := strings.Split(line, "-")
		rStart, _ := strconv.Atoi(ri[0])
		rEnd, _ := strconv.Atoi(ri[1])
		freshIngredientRanges = append(freshIngredientRanges, []int{rStart, rEnd})
	}

	availableIngredients := []int{}
	for _, line := range strings.Split(inputSections[1], "\n") {
		ingredientId, _ := strconv.Atoi(line)
		availableIngredients = append(availableIngredients, ingredientId)
	}

	fmt.Printf("Part 1: %v\n", part1(&freshIngredientRanges, &availableIngredients))
	fmt.Printf("Part 2: %v\n", part2(&freshIngredientRanges))
}

func part1(freshIngredientRanges *[][]int, availableIngredients *[]int) string {
	numFreshIngredients := 0

	for _, i := range *availableIngredients {
		for _, r := range *freshIngredientRanges {
			if r[0] <= i && i <= r[1] {
				numFreshIngredients++

				break
			}
		}
	}

	return strconv.Itoa(numFreshIngredients)
}

func part2(freshIngredientRanges *[][]int) string {
	mergedRanges := [][]int{}

	for rIdx, r := range *freshIngredientRanges {
		overlapIdx := -1
		insertIdx := -1

		for mIdx, mR := range mergedRanges {
			if rangesOverlap(r, mR) {
				overlapIdx = mIdx
				break
			}

			if r[0] < mR[0] {
				fmt.Printf("%d < %d, insertIdx=%d\n", r[0], mR[0], mIdx)
				insertIdx = mIdx
				break
			}
		}

		if overlapIdx > -1 {
			mergedRanges[overlapIdx] = mergeRanges(mergedRanges[overlapIdx], r)

			for mIdx := 0; mIdx < len(mergedRanges); mIdx++ {
				mR := mergedRanges[mIdx]
				for nIdx := mIdx + 1; nIdx < len(mergedRanges); nIdx++ {
					nR := mergedRanges[nIdx]
					if rangesOverlap(nR, mR) {
						mergedRanges[mIdx] = mergeRanges(mR, nR)                             // Merge
						mergedRanges = append(mergedRanges[:nIdx], mergedRanges[nIdx+1:]...) // Slice out dupe
					}
				}
			}
		} else {
			if insertIdx > -1 && insertIdx < len(mergedRanges) {
				// insert at insertIdx
				mergedRanges = append(mergedRanges[:insertIdx+1], mergedRanges[insertIdx:]...)
				mergedRanges[insertIdx] = r
			} else {
				// append at end
				mergedRanges = append(mergedRanges, r)
			}
		}

		for _, r := range mergedRanges {
			fmt.Printf("%d-%d\n", r[0], r[1])
		}
		fmt.Printf("^^Loop %d\n\n", rIdx)
	}

	total := 0
	for _, r := range mergedRanges {
		total += 1 + r[1] - r[0]
	}

	return strconv.Itoa(total)
}

func max(a int, b int) int {
	if a > b {
		return a
	} else {
		return b
	}
}

func min(a int, b int) int {
	if a < b {
		return a
	} else {
		return b
	}
}

func rangesOverlap(a []int, b []int) bool {
	return a[0] >= b[0] && a[0] <= b[1] || a[1] >= b[0] && a[1] <= b[1]
}

func mergeRanges(a []int, b []int) []int {
	return []int{min(a[0], b[0]), max(a[1], b[1])}
}
