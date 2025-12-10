# PromQL Basic

Reference: <https://youtu.be/RC1ivt-ZN_U?si=3F_cNSP2rSoSzjbm>

## Types of metrics

- counter
- guage
- histogram

## Counter metrics

Metrics which only goes up (eg http request)

## Guage metrics

Metrics which goes up and down very frequently (eg cpu usage)

## Histogram metrics

Metrics are devided into bins/buckets (eg response time per requets)

## basic filtertion

- {x=y}
- {x!=y} negation
- {x=~"regexhere"} regex filter
- {x!~"regexhere"} negative regex i.e exclude matching regex

## Time series

- if query is performed without specifying time range, it returns the up to date value and the value is call `instant vector`

```http_request_total```

- if query is performed with time range specified inside [], it returns a range of specified time and the output is called `range vector`

```http_request_total[5m]```

## promQL Functions

### rate(_range_vector): checks for frequency

- can only be used with counters and native histograms
- takes time range as an input and returns average of that time range

```rate(prometheus_http_requests_total{handler=~"/api/v1/.*"}[5m])```

### irate(_range_vector): checks for volatility

- can only be used with counters
- similar to rate but it uses only last two data points from _range_vector and calculates instant rate of increase

```irate(prometheus_http_requests_total{handler=~"/api/v1/.*"}[5m])```

### delta(_range_vector)

- can only be used with guages and native histograms
- calculates difference between first and last value of range vector and returns an instant vector

```delta(node_cpu_scaling_frequency_hertz{instance='10.0.2.254:9100'}[10m])```

## Aggregation operators

input vectors -> instant vectors

### sum(_input_vector)

```sum(rate(prometheus_http_requests_total[30m]))```

### avg(_input_vector)

```avg(rate(prometheus_http_requests_total[30m]))```

### max(_input_vector)

```max(rate(prometheus_http_requests_total[30m]))```

### min(_input_vector)

```min(rate(prometheus_http_requests_total[30m]))```

## Grouping By

```sum by (job) (rate(prometheus_http_requests_total[5m]))```

## over time

- agg_over_time(_range_vector) -> instant vector
- sum_over_time(_range_vector) -> instant vector
- max_over_time(_range_vector) -> instant vector
- min_over_time(_range_vector) -> instant vector

## Histogram Queries

- simple histogram query \
    ```sum by (le) (prometheus_http_request_duration_seconds_bucket{handler="/metrics"})```

- histogram_quantile \
    __Formula:__ *histogram_quantile(percentile, histogram)* \
```histogram_quantile(0.95, sum by (le) (prometheus_http_request_duration_seconds_bucket{handler="/metrics"}))```

### Averages and Totals

- Average: \
__Formula:__ *rate(request_duration[duration]) / rate(total_requests[duration]) =  seconds per request*
```rate(prometheus_http_request_duration_seconds_sum{handler=~"/api/v1/.*"}[5m]) / rate(prometheus_http_request_duration_seconds_count{handler=~"/api/v1/.*"}[5m])```

- Totals:\
__Function__: *increase(range_vector)*
  - Measure how a counter value increases with time.
  - Should only be used with counters.
```increase(prometheus_http_requests_total{handler="/metrics"}[5m])```

  __Function__: *delta(range_vector)*
  - Measure how a guage value increases with time.

### Label Manipulation

- __Function:__ *label_replace(metric, new_label, value, old_label, regex)*
  - metric: metric whose label is to be replaced
  - new_label: new label
  - value: value of new label
  - old_label: old label to be replaced
  - regex: regex to match the old_label
  ```label_replace(prometheus_http_requests_total, "api", "$1", "handler", "(/.*)")```

