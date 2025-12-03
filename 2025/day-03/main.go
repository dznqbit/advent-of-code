// http://adventofcode.com/2025/day/3
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

	return strings.Join(lines, "")
}

func main() {
	input := readInput()
	batteryBanks := strings.Split(strings.TrimSpace(input), "\n")

	fmt.Printf("Part 1: %v\n", part1(batteryBanks))
	fmt.Printf("Part 2: %v\n", part2(batteryBanks))
}

func part1(batteryBanks []string) int {
	var totalJoltage = 0

	for _, bank := range batteryBanks {
		bankRunes := []rune(bank)
		var n1Idx int = 0
		var n2Idx int = 1

		for i := 1; i < len(bankRunes); i++ {
			c := bankRunes[i]
			n1 := bankRunes[n1Idx]
			n2 := bankRunes[n2Idx]

			if c > n1 && i < len(bankRunes)-1 {
				n1Idx = i
				n2Idx = i + 1
				continue
			}

			if c > n2 && n2Idx != n1Idx {
				n2Idx = i
			}
		}

		n, _ := strconv.Atoi(fmt.Sprintf("%c%c", bankRunes[n1Idx], bankRunes[n2Idx]))

		totalJoltage += n
	}

	return totalJoltage
}

// Given a string + list of current "max" indices, update the indices in-place if they're larger
// Avoid using slices on bankRunes because that would offset the indices in idx
func joltagiestIndices(bankRunes []rune, idx []int) {
	if len(idx) == 1 {
		for i := idx[0]; i < len(bankRunes); i++ {
			if bankRunes[i] > bankRunes[idx[0]] {
				idx[0] = i
			}
		}
	} else {
		for i := idx[0]; i < len(bankRunes)-(len(idx)-1); i++ {
			if bankRunes[i] > bankRunes[idx[0]] {
				idx[0] = i

				for k := range idx {
					idx[k] = i + k
				}
			}
		}

		joltagiestIndices(bankRunes, idx[1:])
	}
}

// Now, you need to make the largest joltage by turning on exactly twelve batteries within each bank.
func part2(batteryBanks []string) int {
	var totalJoltage = 0

	for _, bank := range batteryBanks {
		bankRunes := []rune(bank)
		idx := []int{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

		joltagiestIndices(bankRunes, idx)
		joltagiestBank := []rune{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
		for i := range idx {
			joltagiestBank[i] = bankRunes[idx[i]]
		}

		n, _ := strconv.Atoi(string(joltagiestBank))

		totalJoltage += n
	}

	return totalJoltage
}
