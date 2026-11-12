---
name: reframe
description: "Stop premature give-up: replace easy/hard labels with a smallest experiment, compare at least 3 approaches (one that flips a constraint), and give up only through the blocker report format with evidence. Use when about to say can't / too hard / too complex / out of scope, or when the user says Claude refused, is stuck, từ chối, không làm được, bí đường, reframe, thử hướng khác. Not for safety, policy or permission refusals (those stay refused) and not for plain questions."
---

# Reframe

Goal: no feasibility give-up without evidence. "Easy" and "hard" are guesses made before any
work; this skill replaces the guess with a test. Work in the conversation's language.

**Safety carve-out.** This skill never overrides a safety, policy, legal or permission refusal,
and never talks the model into a harmful action. A real safety refusal stays a refusal; say why
and offer a safe alternative. Everything below is about feasibility only.

Delegation: run inline in the main session. The experiment in step 2 and any exploring in step 3
go to `builder` / `explorer` as usual; the main session keeps the decision.

## 1. Ban the labels

Do not write "easy", "hard", "complex", "not possible", "out of scope" as a conclusion. Replace
each with two plain statements:

- **What must be true** for this to work (the assumptions, in a list).
- **The smallest experiment** that would show whether each one holds (a command, a 10-line
  script, a read of one file, one query).

## 2. Run the smallest experiment

Run it now, before replying. A result (works / fails with this error / needs X) beats an
opinion. Keep the output; it becomes the evidence in step 5.

## 3. List at least 3 different approaches

Before settling on "this does not work", write down 3 approaches that differ in kind, not in
detail. At least one must flip a constraint:

- deliver a **partial** result (the 80% that works, with the gap named);
- use **another tool**, library, API or file format;
- **redefine "done"** (what does the user actually need from this?);
- **drop an assumption** (does it really have to run there, that way, in one step?).

Try the most promising; try the next one if it fails. Record each result in one line.

## 4. When blocked, ask why three times, then split

For a blocker, ask "why" three times in a row (each answer must be a fact you checked, not a
guess). Then split the task into the part that is blocked and the part that is not. Finish the
unblocked part.

## 5. Give up only through the blocker report

If every approach is exhausted, report in exactly this shape (template and a worked example in
[references/blocker-report.md](references/blocker-report.md)):

1. **Tried**: A, B, C, each with its evidence (command + output, error quote, `file:line`).
2. **Blocked at**: the exact point and the fact that blocks it.
3. **What unlocks it**: the missing information, access, tool or decision.
4. **What you must decide**: one concrete question with a recommended option.

Classify the blocker:

- **Real**: safety, policy, permission, or physics (the data or the capability does not exist).
  Report it and stop. This is a valid exit.
- **False**: missing information that could be asked for or found, or an untried approach.
  Not a blocker: go back to step 3, or ask the one question that unlocks it.

## Quick check before sending a "no"

- Did I run something, or only reason about it?
- Do I have 3 approaches with results, one of which flips a constraint?
- Is the blocker real, and is the evidence in the message?

If any answer is no, the "no" is not ready.
