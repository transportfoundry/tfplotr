#' Plot area plot of time use.
#'
#' Assumes \code{start} and \code{end} in \code{tbl} and the \code{x_max} value
#' are in simulation time (minutes from 4:00am) with \code{end} missing for the
#' last activity of every person.
#'
#' @param tbl tbl of data with at least the following columns: \code{per_id},
#' \code{event_type}, \code{start}, \code{end}.
#' @param x_max Maximum time on x-axis.
#'
#' @return A plot.
#'
#' @export
plot_time_use <- function(tbl, x_max = 1440) {

  times <- seq(0, x_max, by = 15)

  activities_at_time <- list()
  for (i in times) {
    activities_at_time[[i+1]] <- tbl %>%
      filter((start <= i & i < end & start != end) |
               (start <= i & is.na(end))) %>%
      mutate(time = i) %>%
      select(time, per_id, event_type)
  }

  x <- bind_rows(activities_at_time) %>%
    group_by(time, event_type) %>%
    summarise(count = n()) %>%
    tidyr::spread(event_type, count, fill = 0) %>%
    tidyr::gather(event_type, count, -time) %>%
    group_by(time) %>%
    mutate(pct = count / sum(count) * 100)

  num_home <- tbl %>%
    filter(start == 0, is.na(end)) %>%
    nrow() %>% as.numeric()
  tot <- tbl %>%
    group_by(per_id) %>%
    summarize() %>%
    nrow() %>% as.numeric()
  pct_home <- num_home / tot * 100

  # Plot
  ggplot(x, aes(x = as.numeric(time), y = pct, fill = event_type)) +
    geom_area() +
    geom_hline(aes(yintercept = pct_home), color = "white") +

    theme_tf() +
    theme(legend.title = element_blank()) +
    xlab("Military Time") + ylab("Percent of People") +
    scale_fill_manual(
      values = as.vector(c(solarized["base03"], solarized["violet"],
                           solarized["cyan"], solarized["base3"]))) +
    scale_x_continuous(
      breaks = seq(0, x_max, by = 60*4),  # label every four hours
      labels = tfr::get_military_time)
}