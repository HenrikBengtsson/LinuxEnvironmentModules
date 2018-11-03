help([[
R: The R Programming Language
]])

local name = myModuleName()
local version = myModuleVersion()
whatis("Version: " .. version)
whatis("Keywords: Programming, Statistics")
whatis("URL: https://www.r-project.org/")
whatis("Description: The R programming language. Examples: `R --version` and `Rscript --version`.")

local root = os.getenv("SOFTWARE_ROOT")
local home = pathJoin(root, "R-" .. version)
prepend_path("PATH", home .. "/bin")
prepend_path("MANPATH", home .. "/share/man")
