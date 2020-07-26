# Getting Started

All functions of packer are meant to be used within R packages, these provide a robust foundations for writing most R code and soon JavaScript. Therefore one always starts from an empty package.

Below we create a package named "alerts" via [usethis](http://usethis.r-lib.org/), which is a dependency of packer and so should already be installed on your machine.

```r
# creates package
usethis::create_package('alerts')
```

```
▶ Rscript -e "usethis::create_package('alerts')"
✔ Creating 'alerts/'
✔ Setting active project to '/home/Packages/alerts'
✔ Creating 'R/'
✔ Writing 'DESCRIPTION'
Package: alerts
Title: What the Package Does (One Line, Title Case)
Version: 0.0.0.9000
Authors@R (parsed):
    * First Last <first.last@example.com> [aut, cre] (YOUR-ORCID-ID)
Description: What the package does (one paragraph).
License: `use_mit_license()`, `use_gpl3_license()` or friends to
    pick a license
Encoding: UTF-8
LazyData: true
Roxygen: list(markdown = TRUE)
RoxygenNote: 7.1.1.9000
✔ Writing 'NAMESPACE'
✔ Setting active project to '<no active project>'
```

## Scaffolds

Then comes on of the core concepts of packer: scaffolds. Scaffolds are basic structures that enables using JavaScript with R in a more structure way, via webpack. There are currently 5 scaffolds available.

* `scaffold_widget` - Scaffold an [htmlwidgets](http://www.htmlwidgets.org/) with webpack.
* `scaffold_golem` - Use webpack with [golem](http://golemverse.org/).
* `scaffold_extension` - Scaffold a shiny extension, e.g.: [shinyjs](https://deanattali.com/shinyjs/) or [waiter](https://waiter.john-coene.com/).
* `scaffold_input` - Scaffold a custom shiny input.
* `scaffold_output` - Scaffold a custom shiny output.

<Tip title="Multiple Scaffolds" text="Most scaffolds can be used more than once per package, e.g.: to create multiple inputs." />

Let's demonstrate with a scaffold for a shiny extension. In packer a shiny extension is a package that extends shiny via JavaScript; package such as [waiter](https://waiter.john-coene.com/#/) or [shinyjs](https://deanattali.com/shinyjs/). The function takes a single argument `name` which will be used to define the name of R and JavaScript functions, files, modules, etc.

```r
packer::scaffold_extension("ask")
```

```
── Scaffolding shiny extension ─────────────────────────────────────── ask ── 

✔ Initialiased npm
✔ Created `srcjs/exts` directory
✔ Created `inst/packer` directory
✔ webpack, webpack-cli installed
✔ Added npm scripts
✔ Created webpack config file
✔ Created `srcjs/index.js` file
✔ Created input module directory
✔ Created JavaScript extension file
✔ Added path shiny resource
✔ Created R functions

── Adding files to .gitignore and .Rbuildignore ──

✔ Setting active project to '/home/jp/Projects/alerts'
✔ Adding '^srcjs$' to '.Rbuildignore'
✔ Adding '^node_modules$' to '.Rbuildignore'
✔ Adding '^package\\.json$' to '.Rbuildignore'
✔ Adding '^package-lock\\.json$' to '.Rbuildignore'
✔ Adding '^webpack\\.config\\.js$' to '.Rbuildignore'
✔ Adding 'node_modules' to '.gitignore'

── Adding packages to Imports ──

✔ Adding 'shiny' to Imports field in DESCRIPTION
● Refer to functions with `shiny::fun()`

── Scaffold built ──

ℹ Run `bundle` to build the JavaScript files
```

As hinted at by the messages above this does many things:

1. Initialises npm
2. Installs webpack
3. It creates an `srcjs` directory containing the JavaScript files
4. Creates a `webpack.config.js` file to configure webpack
5. Creates `inst` directory to place bundles
6. Creates R files and functions
7. Adds relevant files to the `.gitignore` and `.Rbuildignore`
8. Adds relevant packages to `Imports`

When run from an interactive session packer also opens the most pertinent files in your default editor or IDE. With the scaffold the package now look like this. 

```
.
├── DESCRIPTION
├── NAMESPACE
├── R
│   ├── ask.R
│   └── zzz.R
├── inst
│   └── packer
├── node_modules
│   ├── ...
├── package-lock.json
├── package.json
├── srcjs
│   ├── exts
│   │   └── ask.js
│   └── index.js
└── webpack.config.js
```

It created two R files, `ask.R` which contains exported functions relevant to the extensions, and `zzz.R` which contains the `.onLoad` function to serve the JavaScript files required to run the extension. It also created the `inst/packer` directory which is currently empty but will eventually contain the bundled JavaScript file(s).

The function also initialised npm which created the `node_modules` directory (containing numerous npm packages), as well as the `package.json` and `package-lock.json`, packer also added the necessary scripts to `package.json` so one should not need to interact with those files directly.

Finally, the webpack configuration file was created, along with the `srcjs` directory containing core JavaScript files of the extension.

### R files

**zzz.R**

This file contains the `shiny::addResourcePath` function that will serve the JavaScript files bundled by packer. Note that the prefix follows the `packageName-assets` pattern where `packageName` is the name of the package from which the scaffold is run.

```r
.onLoad <- function(libname, pkgname){
  path <- system.file("packer", package = "alerts")
  shiny::addResourcePath('alerts-assets', path)
}
```

**ask.R**

Named after the scaffold this file contains the two exported R functions, both named after the scaffold.

1. `useAsk` to import the dependencies, this is meant to be placed in a shiny UI.
2. `ask` function that sends a message to the Shiny front-end.

```r
#' Dependencies
#' 
#' Include dependencies, place anywhere in the shiny UI.
#' 
#' @importFrom shiny singleton tags
#' 
#' @export
useAsk <- function(){
  singleton(
    tags$head(
      tags$script(src = "alerts-assets/ask.js")
    )
  )
}

#' Show an alert
#' 
#' Show a vanilla JavaScript alert.
#' 
#' @param msg Message to display.
#' @param session A valid shiny `session`.
#'  
#' @examples 
#' library(shiny)
#' 
#' ui <- fluidPage(
#'   useAsk(),
#'   verbatimTextOutput("response")
#' )
#' 
#' server <- function(input, output){
#' ask("Please enter something:")
#'  output$response <- renderPrint({
#'    input$askResponse
#'  })
#' }
#' 
#' if(interactive())
#'  shinyApp(ui, server)
#' 
#' @export
ask <- function(msg, session = shiny::getDefaultReactiveDomain()){
  session$sendCustomMessage("ask-alert", msg)
}
```

### JavaScript files

**ask.js**

The `ask.js` file contains the message handler.

```js
import Shiny from 'shiny';

Shiny.addCustomMessageHandler('ask-alert', function(msg){
  let response = prompt(msg);
  Shiny.setInputValue('askResponse', response);
})
```

**index.js**

The `index.js` file only contains one line to import the ask module. This file is actually not used by packer by default but may come in handy if one wants to bundle multiple extensions, inputs, or other into a single file.

```js
import './exts/ask.js';
```

## Bundle

You can then run `packer::bundle` to bundle the files in `srcjs`, the webpack config file includes the correct entry points and output directory. The entry points and output directories will depend on the scaffold, shiny extensions' entry points are placed in the `srcjs/exts` directory and output in `inst/packer` upon bundle. 

```r
packer::bundle()
```

```
✔ Bundled!
```

The bundle above therefore reads `exts/ask.js` and generates `inst/packer/ask.js`. Note that packer also scaffolded the `index.js` file and will keep it updated with newly added extensions, inputs, outputs, and widgets. This might be handy were one want to bundle multiple scaffold into a single JavaScript file.

One can then document and build the package to test the toy extension that was scaffolded. The `ask.R` file that generated includes an example of shiny apps that runs the extension.

```r
devtools::document()
devtools::install()
```

```r
library(alerts)
library(shiny)

ui <- fluidPage(
  useAsk(),
  verbatimTextOutput("response")
)

server <- function(input, output){
ask("Please enter something:")
 output$response <- renderPrint({
   input$askResponse
 })
}

if(interactive())
 shinyApp(ui, server)
```

![_media](../_media/get-started.gif)
