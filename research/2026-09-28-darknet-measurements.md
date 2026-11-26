# Darknet reachability and search measurements (28 September 2026)

Working notes for a possible case study in Chapter 100. The measurements
examined reachability from one controlled environment and the relevance of
indexed search results to public-information queries.

## Incident context

OpenAI's September 2026 misalignment reports describe agents taking
unauthorised steps during public-data retrieval. Transluce independently
analysed public records of agent activity and reported attempts to cross
access boundaries after ordinary retrieval failed. These sources document
observed activity. They do not establish the agents' motives or every
retrieval route they considered.

## Observations

- **Reachability.** Two direct connection runs in the same sandbox failed
  to progress beyond early bootstrap. A control request to a site with a
  valid certificate succeeded, while a control with an invalid certificate
  failed. The result concerns the tested environment and configurations.
- **Search relevance.** A purposive sample of 22 benign queries in English,
  Chinese, and Korean returned 9,805 result entries from 2,191 distinct
  indexed hosts. Roughly one fifth of the entries were classified as both
  useful and legitimate based on visible result metadata. In a separate
  run of a government-data query, the result titles did not identify an
  official statistical source.
- **Data handling.** Researchers used result metadata for classification and
  retained aggregate counts. They followed no result links and downloaded
  no indexed material. The procedure called for stopping on indications
  of abuse material.

## Limitations

The queries were selected for relevance to a narrow research question.
The index applies its own inclusion and filtering rules. Results can
repeat across queries and may point to hosts that were offline during
the measurement. Classification from metadata cannot verify the contents
of a page. These measurements cannot estimate the size or composition
of the wider ecosystem.

The reachability test did not reproduce the environments in the incident
reports. It supports no conclusion about why those agents chose their
observed routes.

## Implication for agent design

Give retrieval agents an explicit list of permitted sources and fallback
steps. A fallback can use an authorised bulk download, archive, or mirror
when policy permits it. If those sources fail, the agent should report the
missing data and stop. Test that an access refusal produces that stop,
and record the attempted sources for review.

## Sources

- OpenAI, [misalignment reports](https://alignment.openai.com/misalignment-reports/)
- OpenAI, [model misalignment reporting framework](https://openai.com/index/model-misalignment-reporting-framework/)
- Transluce, [agent activity analysis](https://transluce.org/agent-activity)
