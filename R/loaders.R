#' Use Styles
#' 
#' Installs loaders and adds relevant configuration rules to `srcjs/config/loaders.json`.
#' 
#' @param test Test regular expression test which files should be transformed by the loader.
#' 
#' @details This will let you import styles much like any other modules, e.g.: `import './styles.css'`.
#' 
#' @section Packages:
#' 
#' * [use_loader_css()] - installs and imports `style-loader` and `css-loader` packages as dev.
#' * [use_loader_sass()] - installs and imports `style-loader`, `css-loader`, and `sass-loader` as dev.
#' 
#' @name style_loaders
#' @export
use_loader_css <- function(test = "\\.css$"){
  assert_that(has_scaffold())
  use_loader_rule(c("style-loader", "css-loader"), test = test)
}

#' @rdname style_loaders
#' @export
use_loader_sass <- function(test = "\\.s[ac]ss$/i"){
  assert_that(has_scaffold())
  use_loader_rule(c("style-loader", "css-loader", "sass-loader"), test = test)
}

#' Use Pug Loader
#' 
#' Adds the loader for the pug templating engine.
#' 
#' @inheritParams style_loaders
#' 
#' @export 
use_loader_pug <- function(test = "\\.pug$"){
  assert_that(has_scaffold())
  use_loader_rule("pug-loader", test = test)
}

#' Use babel Loader
#' 
#' Adds the loader for babel comiler to the loader configuration file.
#' 
#' @inheritParams style_loaders
#' @param use_eslint Whether to also add the ESlint loader.
#' 
#' @details The `use_elsint` argument is useful here as loaders have
#' to be defined in the correct order or files might be checked after 
#' being processed by babel.
#' 
#' @details Excludes `node_modules` by default.
#' 
#' @export 
use_loader_babel <- function(test = "\\.(js|jsx)$", use_eslint = FALSE){
  assert_that(has_scaffold())

  pkgs <- "babel-loader"
  if(use_eslint) pkgs <- c(pkgs, "eslint-loader")
  use_loader_rule(pkgs, test = test, exclude = "/node_modules/")
}

#' Use Vue Loader
#' 
#' Adds the Vue loader to the loader configuration file.
#' 
#' @inheritParams style_loaders
#' 
#' @details Every time a new version of Vue is released, a corresponding version of `vue-template-compiler` 
#' is released together. The compiler's version must be in sync with the base Vue package so that `vue-loader`
#' produces code that is compatible with the runtime. This means every time you upgrade Vue in your project, 
#' you should upgrade `vue-template-compiler` to match it as well.
#' 
#' @export 
use_loader_vue <- function(test = "\\.vue$"){
  assert_that(has_scaffold())
  use_loader_rule(
    c("vue-loader", "vue-template-compiler"), 
    test = test, exclude = "/node_modules/", 
    use = list("vue-loader")
  )
}

#' Use Mocha Loader
#' 
#' Adds the [`mocha-loader`](https://webpack.js.org/loaders/mocha-loader/) for tests.
#' 
#' @inheritParams style_loaders
#' 
#' @details Excludes `node_modules` by default.
#' 
#' @export 
use_loader_mocha <- function(test = "\\.test\\.js$"){
  assert_that(has_scaffold())
  use_loader_rule("mocha-loader", test = test, exclude = "/node_modules/")
}

#' Use Coffee Loader
#' 
#' Adds the [`coffee-loader`](https://webpack.js.org/loaders/coffee-loader/) to use
#' cofeescript.
#' 
#' @inheritParams style_loaders
#' 
#' @details Excludes `node_modules` by default.
#' 
#' @export 
use_loader_coffee <- function(test = "\\.coffee$"){
  assert_that(has_scaffold())
  use_loader_rule("coffee-loader", test = test)
}

#' Use File Loader
#' 
#' Adds the [`file-loader`](https://webpack.js.org/loaders/file-loader/) 
#' to resolve files: `png`, `jpg`, `jpeg`, and `gif`.
#' 
#' @inheritParams style_loaders
#' 
#' @export 
use_loader_file <- function(test = "\\.(png|jpe?g|gif)$/i"){
  assert_that(has_scaffold())
  use_loader_rule("file-loader", test)
}

#' Use ESlint
#' 
#' Adds the [`eslint-loader`](https://github.com/webpack-contrib/eslint-loader) 
#' to resolve files: `png`, `jpg`, `jpeg`, and `gif`.
#' 
#' @inheritParams style_loaders
#' 
#' @export 
use_loader_eslint <- function(test = "\\.(js|jsx)$"){
  assert_that(has_scaffold())
  .Deprecated(
    "add_plugin_eslint",
    package = "packer",
    "The loader will soon be deprecated, it is advised to use the plugin instead."
  )
  use_loader_rule("eslint-loader", test)
}

#' Add a Loader Ruée
#' 
#' Adds a loader rule that is not yet implemened in packer.
#' 
#' @inheritParams style_loaders
#' @param packages NPM packages (loaders) to install.
#' @param use Name of the loaders to use for `test`.
#' @param ... Any other options to pass to the rule.
#' 
#' @details Reads the `srcsjs/config/loaders.json` and appends the rule.
#' 
#' @export 
use_loader_rule <- function(packages, test, ..., use = as.list(packages)){
  assert_that(has_scaffold())
  assert_that(not_missing(packages))

  npm_install(packages, scope = "dev")

  # message modifications
  loader <- list(
    test = test,
    use = use,
    ...
  )
  loader_add(loader)
  
  # wrap up
  loader_msg(packages)
}

#' Add loader to config file
#' 
#' Check if module rule already exists before adding rule.
#' 
#' @param loader `list` defining the loader rules.
#' 
#' @noRd 
#' @keywords internal
loader_add <- function(loader){
  json_path <- "srcjs/config/loaders.json"

  # check
  assert_that(fs::file_exists(json_path), msg = "Cannot find loader config file")

  # read loaders
  loaders <- jsonlite::read_json(json_path)

  # check if test already set
  tests <- sapply(loaders, function(x) x$test)
  if(loader$test %in% tests){
    cli::cli_alert_info("A loader is already used for test {.val {loader$test}}: appending loader to existing entry.")
    index <- c(1:length(loader$test))[loader$test == tests]
    loaders[[index]]$use <- c(loaders[[index]]$use, loader$use) 
  } else {
    loaders <- append(loaders, list(loader))
  }

  save_json(loaders, json_path)
}

#' @noRd 
#' @keywords internal
loader_msg <- function(loaders){
  cli::cli_alert_success("Added loader rule for {.val {loaders}}\n")
}