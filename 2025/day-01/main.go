// http://adventofcode.com/2025/day/1
package main

import (
	"bufio"
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

	fmt.Printf("Part 1: %v\n", part1(input))
	fmt.Printf("Part 2: %v\n", part2(input))
}

type Safe struct {
	position int
}

type Direction int

const (
	Left Direction = iota
	Right
)

func parseDirection(s string) Direction {
	if s == "L" {
		return Left
	}

	if s == "R" {
		return Right
	}

	panic(fmt.Errorf("Could not parse direction: %s", s))
}

var directionName = map[Direction]string{
	Left:  "L",
	Right: "R",
}

func (d Direction) String() string {
	return directionName[d]
}

type Instruction struct {
	direction Direction
	amount    int
}

func (i Instruction) String() string {
	return fmt.Sprintf("%s%d", i.direction, i.amount)
}

func parseInstruction(s string) *Instruction {
	direction := parseDirection(s[0:1])
	amount, _ := strconv.ParseInt(s[1:], 0, 64)

	i := Instruction{direction: direction, amount: int(amount)}

	return &i
}

func Map[T, U any](seq iter.Seq[T], f func(T) U) iter.Seq[U] {
	return func(yield func(U) bool) {
		for a := range seq {
			if !yield(f(a)) {
				return
			}
		}
	}
}

func part1(input string) string {
	var instructions []Instruction
	for s := range strings.FieldsSeq(input) {
		instructions = append(instructions, *parseInstruction(s))
	}

	var safe Safe = Safe{position: 50}
	var timesHitZero = 0

	for _, i := range instructions {
		var newPosition int
		if i.direction == Left {
			newPosition = safe.position - (i.amount % 100)
		} else {
			newPosition = safe.position + (i.amount % 100)
		}

		if newPosition < 0 {
			newPosition = 100 + newPosition
		}

		if newPosition > 99 {
			newPosition = newPosition % 100
		}

		safe.position = newPosition

		if safe.position == 0 {
			timesHitZero += 1
		}
	}

	return strconv.Itoa(timesHitZero)
}

func part2(input string) string {
	var instructions []Instruction
	for s := range strings.FieldsSeq(input) {
		instructions = append(instructions, *parseInstruction(s))
	}

	var safe Safe = Safe{position: 50}
	var timesHitZero = 0

	for _, i := range instructions {
		var newPosition int
		oldPosition := safe.position

		if i.direction == Left {
			power := i.amount / 100
			timesHitZero += power

			scaledAmount := i.amount % 100
			if scaledAmount > oldPosition {
				if oldPosition != 0 {
					timesHitZero += 1
				}

				newPosition = 100 + oldPosition - scaledAmount
			} else {
				newPosition = oldPosition - scaledAmount
			}
		} else {
			power := i.amount / 100
			timesHitZero += power

			scaledAmount := i.amount % 100
			if oldPosition+scaledAmount > 99 {
				if oldPosition+scaledAmount != 100 {
					timesHitZero += 1
				}
				newPosition = oldPosition + scaledAmount - 100
			} else {
				newPosition = oldPosition + scaledAmount
			}
		}

		if newPosition == 0 {
			timesHitZero += 1
		}

		fmt.Printf("%d => %v => %d (%d)\n", oldPosition, i, newPosition, timesHitZero)
		safe.position = newPosition

		// LAST KNOWN POINT OF SANITY
		// if i.direction == Left {
		// 	newPosition = oldPosition - i.amount
		// } else {
		// 	newPosition = oldPosition + i.amount
		// }

		// if newPosition < 0 {
		// 	absNewPosition := newPosition * -1

		// 	if oldPosition == 0 {
		// 		timesHitZero += absNewPosition / 100
		// 	} else {
		// 		timesHitZero += 1 + (absNewPosition / 100)
		// 	}

		// 	newPosition = 100 - (absNewPosition % 100)
		// }

		// if newPosition > 99 {
		// 	if newPosition > 100 {
		// 		timesHitZero += newPosition / 100
		// 	}

		// 	newPosition = newPosition % 100
		// }

		// if newPosition == 0 {
		// 	timesHitZero += 1
		// }

		// fmt.Printf("%d => %v => %d (%d)\n", oldPosition, i, newPosition, timesHitZero)
		// safe.position = newPosition

		// 2936 too low
		// 5955 incorrect
		// 5919 incorrect
		// 6051 incorrect
		// 6143 incorrect
		// 6057 too hi
		// 6825 too hi
	}

	return strconv.Itoa(timesHitZero)
}
