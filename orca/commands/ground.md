---
description: Ground the current decision/direction against 20+ real-world sources — mainstream approaches, edge cases, and how people actually solve it
argument-hint: [optional: topic or decision to ground — defaults to what's currently being discussed]
allowed-tools: Agent, WebSearch, WebFetch
disable-model-invocation: true
---

Ground the following in real-world practice: $ARGUMENTS

If no topic was given above, first identify the decision or direction currently
under discussion in this conversation — the thing about to be built or decided —
and state it back in one line before proceeding. Don't guess silently; if it's
ambiguous, name the ambiguity and pick the most likely reading.

## 1. Decompose

Break the topic into 3-4 distinct research angles. For a typical technical
decision that's usually:
- the mainstream/standard approach(es) in current practice
- known edge cases, failure modes, and how they're mitigated
- notable alternative approaches and their tradeoffs
- recent (last 1-2 years) shifts in best practice, if any

Adjust the angles to fit the actual topic rather than forcing these four if
they don't apply.

## 2. Research in parallel

Dispatch one `orca:ground-subagent` per angle (Agent tool, subagent_type:
orca:ground-subagent), all in a single message so they run concurrently. Give
each one the topic and its specific angle in the task description — the
subagent already knows how to gather sources, cap domains per source, cite
everything, and refuse to fabricate when nothing real exists for its angle.

## 3. Synthesize

Combine the subagents' results into:

- **Consensus approach** — what most sources agree on
- **Edge cases & how people handle them** — one line each, sourced
- **Where sources disagree** — state it explicitly, don't silently pick a side
- **How this maps onto the current direction** — does the plan on the table
  match, partially match, or diverge from what the research shows, and why
  that matters here
- **Sources** — full list as markdown links, deduplicated across *all*
  subagents (not just within each one) and capped domain-diverse overall —
  if two subagents independently cite the same domain, keep the most
  on-topic instances and drop the rest rather than letting the count double up

## 4. Verify before presenting

Re-read the synthesis against the raw source list from step 2. Drop or flag
any claim that isn't actually backed by one of the returned URLs — don't let a
plausible-sounding claim slip through without a real citation behind it.

## 5. Be honest about coverage

If fewer than ~15-20 sources were actually retrievable (searches failed, the
topic is too niche or too internal-only to have public prior art), report the
real count and say so plainly. Never pad the list or fabricate sources to hit
a target number.
