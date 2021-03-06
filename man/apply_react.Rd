% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/react.R
\name{apply_react}
\alias{apply_react}
\title{Apply React}
\usage{
apply_react(use_cdn = TRUE)
}
\arguments{
\item{use_cdn}{Whether to use the CDN for \code{react} and \code{react-dom} (recommended).
This means later importing the dependencies in the shiny UI using \code{reactCDN()},
this function will be created in a \code{R/react_cdn.R}.
The correct instructions to do so are printed to the console by the function.}
}
\description{
Apply React to a project, adds the relevant (babel) loader, installs dependencies,
and creates, updates, or replaces the \code{srcjs/index.js} file.
}
\details{
After running this function and bundling the JavaScript remember to place
the code printed by the function in shiny UI. By default \code{\link[=apply_react]{apply_react()}} does not
bundle \code{react} and \code{react-dom} and thus requires using \code{reactCDN()} to import the
dependencies in the shiny application: this function is created in a \code{R/react_cdn.R}.
}
