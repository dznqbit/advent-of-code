// http://adventofcode.com/2025/day/2
package main

import (
	"bufio"
	"errors"
	"fmt"
	"iter"
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
	ranges, rangeError := parseProductIdRange(input)
	if rangeError != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", rangeError)
		os.Exit(1)
	}

	fmt.Printf("Part 1: %v\n", sumInvalidIds(ranges, findRepeatedNumbers))
	fmt.Printf("Part 2: %v\n", sumInvalidIds(ranges, findRepeatedNumbersPart2))
}

func sumInvalidIds(productIdRanges []ProductIdRange, fn func(p ProductIdRange) []int) string {
	var allInvalidIds []int

	for _, r := range productIdRanges {
		invalidIds := fn(r)
		// fmt.Printf("%v has %d Invalid IDs: %v\n", r, len(invalidIds), invalidIds)

		for _, id := range invalidIds {
			allInvalidIds = append(allInvalidIds, id)
		}
	}

	var sum int
	for _, id := range allInvalidIds {
		sum += id
	}

	return strconv.Itoa(sum)
}

type ProductIdRange struct {
	start int
	end   int
}

// String rep
func (p ProductIdRange) String() string {
	return fmt.Sprintf("[%v-%v]", p.start, p.end)
}

// Iterates from [start, end]
func (p ProductIdRange) all() iter.Seq[int] {
	return func(yield func(int) bool) {
		for i := p.start; i <= p.end; i++ {
			if !yield(i) {
				return
			}
		}
	}
}

func parseProductIdRange(input string) ([]ProductIdRange, error) {
	var ranges []ProductIdRange
	for rangeStr := range strings.FieldsFuncSeq(strings.TrimSpace(input), func(r rune) bool { return r == ',' }) {
		n := strings.Split(rangeStr, "-")
		start, startError := strconv.ParseInt(n[0], 0, 64)
		end, endError := strconv.ParseInt(n[1], 0, 64)

		if startError != nil || endError != nil {
			return ranges, errors.New("Failed to parse range")
		}

		r := ProductIdRange{start: int(start), end: int(end)}
		ranges = append(ranges, r)
	}

	return ranges, nil
}

// Find the invalid IDs by looking for any ID which is made only of some sequence of digits repeated twice.
// So, 55 (5 twice), 6464 (64 twice), and 123123 (123 twice) would all be invalid IDs.
func findRepeatedNumbers(r ProductIdRange) []int {
	var repeatedNumbers []int

	for i := range r.all() {
		iStr := strconv.Itoa(i)

		if len(iStr)%2 == 0 {
			i1 := iStr[:len(iStr)/2]
			i2 := iStr[len(iStr)/2:]

			if i1 == i2 {
				repeatedNumbers = append(repeatedNumbers, i)
			}
		}
	}

	return repeatedNumbers
}

// Now, an ID is invalid if it is made only of some sequence of digits repeated at least twice.
// Examples:
// 12341234 (1234 two times)
// 123123123 (123 three times)
// 1212121212 (12 five times)
// 1111111 (1 seven times)
func findRepeatedNumbersPart2(r ProductIdRange) []int {
	var repeatedNumbers []int

	for i := range r.all() {
		iStr := strconv.Itoa(i)
		iLen := len(iStr)

		for j := iLen / 2; j > 0; j-- {
			if iLen%j != 0 {
				continue
			}

			seq := iStr[:j]
			var numMatches = 1

			for k := 0; k < (iLen/j - 1); k++ {
				kSeq := iStr[(k+1)*j : (k+2)*j]
				if seq == kSeq {
					numMatches++
				} else {
					break
				}
			}

			if numMatches == iLen/j {
				repeatedNumbers = append(repeatedNumbers, i)
				break
			}
		}
	}

	return repeatedNumbers
}
