# Elicitation methods

These are standard critique and reasoning techniques, summarised in atelier's own words.
"Shape" is a loose guide to the output.

## Risk

| Method | What it does | Shape |
|---|---|---|
| Pre-mortem | Assume it has already failed six months from now. Write the post-mortem, then prevent each cause. | failure story → causes → preventions |
| Failure mode analysis | For each component, how can it fail, how would we notice, and what is the blast radius? | component → failure → detection → mitigation |
| Assumption audit | List every assumption, grade how confident we are, and find the cheapest test for the shakiest one. | assumption → confidence → test |
| Inversion | Ask how to guarantee failure, then make sure the plan does none of those things. | sabotage list → guards |
| Cascading failure | Follow one failure through its dependencies. Where does it stop? | trigger → chain → firebreak |
| Chaos scenarios | Kill the network, the DB, the clock, the user's patience. What breaks? | scenario → behaviour → fix |

## Core reasoning

| Method | What it does | Shape |
|---|---|---|
| First principles | Strip it to facts and constraints, then rebuild without inherited assumptions. | facts → rebuild → diff |
| 5 whys | Keep asking why until you reach a root cause you can act on. | why chain → root → action |
| Socratic questioning | Ask probing questions about definitions, evidence and implications. | questions → exposed gaps |
| Second-order thinking | Ask "and then what?" for each consequence. | effect → next effect → risk |
| Steelman | Build the strongest version of the rejected alternative, then compare honestly. | best rival → comparison |
| Problem decomposition | Split into independent parts and check that each one is solved. | tree → leaf status |
| Occam's razor | Remove every part that the simplest explanation or design doesn't need. | parts → removable → simpler version |
| Critique and refine | Name the strengths and weaknesses, then produce an improved version. | strengths/weaknesses → revision |

## Framing

| Method | What it does | Shape |
|---|---|---|
| Reframe the question | Is this the right problem? Restate it three ways. | reframes → best framing |
| Stakeholder lens rotation | Re-read it as each user, the operator, support, security and finance. | lens → concerns |
| Abstraction ladder | Move up (why?) and down (how exactly?) to find the right level. | ladder → chosen level |
| Map vs territory | Where does the model, spec or diagram differ from the real system? | model claim → reality check |

## Collaboration

| Method | What it does | Shape |
|---|---|---|
| Expert panel | Three or four named experts critique it from their fields. | expert → critique → synthesis |
| Red team vs blue team | One side attacks, the other defends. Keep what survives. | attacks → defences → hardened version |
| Six thinking hats | Facts, feelings, risks, benefits, ideas, process: one pass each. | hat → notes |
| Devil's advocate | Argue against the current choice as hard as possible. | counter-case → response |

## Technical

| Method | What it does | Shape |
|---|---|---|
| Boundary and edge-case sweep | Look at empty, max, concurrent, partial-failure and odd inputs. | boundary → handling |
| Security personas | An attacker, an insider and a careless user each try to break it. | persona → attack → guard |
| Performance panel | Look at hot paths, N+1 queries, payload size and cold start. | hotspot → cost → fix |
| Decision record | Write it up as options, drivers, choice and consequences, to expose a weak rationale. | ADR draft |
| Rubber duck, evolved | Explain it step by step to a newcomer and note where the explanation stalls. | walkthrough → stall points |

## Creative

| Method | What it does | Shape |
|---|---|---|
| SCAMPER | Substitute, combine, adapt, modify, put to other use, eliminate, reverse. | prompt → idea |
| What-if scenarios | Change one big variable (10x users, offline, no budget). | scenario → implication |
| Constraint injection | Add an artificial limit to force a simpler design. | constraint → design |
| Subtraction | Remove features one at a time. What still delivers the core value? | removed → still works? |

## Learning

| Method | What it does | Shape |
|---|---|---|
| Feynman technique | Explain it in plain words. Where it gets fuzzy, the understanding is weak. | plain explanation → gaps |
| Hindsight reflection | Look back at what we'd tell our past selves about this kind of work. | lessons → changes |
