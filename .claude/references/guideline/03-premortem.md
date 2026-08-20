# Pre-mortem and Failure Analysis

A pre-mortem is a structured exercise where you imagine a project has failed spectacularly, then work backward to identify what went wrong. It counteracts the natural optimism bias that makes teams gloss over risks during planning.

## Why Pre-mortems Work

Normal planning asks "how do we make this succeed?" — which triggers defensive optimism. A pre-mortem asks "how could this fail?" — which activates critical thinking without appearing negative.

The goal is to surface risks that weren't raised during normal discussion because they felt unwelcome or overly pessimistic.

## The Pre-mortem Protocol

1. **Set the scene** — "Imagine it's six months from now. This project was a complete failure. The worst failure possible. What happened?"
2. **Everyone speaks** — every team member must contribute at least one failure mode
3. **No criticism** — don't debate or dismiss failure modes when raised
4. **Go deep** — for each failure, ask "why did that happen?" until you reach a root cause
5. **Assign ownership** — which risks need mitigation before proceeding?

## Pre-mortem Questions

Use these to probe failure modes:

**Direct pre-mortems:**
- "This fails in production — what went wrong?"
- "If we ship this and it causes problems a year from now, what will we wish we'd asked now?"
- "What would have to be true for this to fail completely?"

**Inversion questions (lighter touch):**
- "What if we did the opposite of what was proposed?"
- "What would have to be true for this approach to be wrong?"
- "What's the cheapest way to prove this is wrong?"

**Risk quantification:**
- "What's the worst-case scenario, realistically?"
- "If X happens, what else breaks?"
- "What's the blast radius if we're wrong?"

## Failure Mode Categories

**Technical failures:**
- Scale doesn't hold under load
- Data loss or corruption
- Security breach
- Integration with dependent systems breaks

**Organizational failures:**
- Team lacks required expertise
- Stakeholder alignment breaks down
- Priority shifts mid-project
- Budget or timeline is unrealistic

**External failures:**
- Market conditions change
- Regulatory landscape shifts
- Competitor releases something better

## Connection to Dig

Dig's Question Repertoire explicitly includes pre-mortems and inversion questions. This reference provides the deeper methodology for conducting them effectively.

## The "Second-Order" Test

For any proposed solution, ask:
- "What happens when this solution interacts with X?"
- "What does this solution make harder to change later?"
- "If we're wrong about our assumption, what breaks?"

This exposes path dependencies and lock-in that aren't visible in happy-path planning.

## Sources

- Klein, G. (2007). "Sources of Power" — on pre-mortem analysis in naturalistic decision-making
- Postmortem bias in organizational learning — the tendency to retroactively explain failures
- NASA mission reviews — historical use of "what could go wrong" analysis
- Feynman diagrams applied to project planning — tracing all possible paths to failure
