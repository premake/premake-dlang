--
-- Name:        d/_preload.lua
-- Purpose:     Define the D language API's.
-- Author:      Manu Evans
-- Created:     2013/10/28
-- Copyright:   (c) 2013-2015 Manu Evans and the Premake project
--

-- TODO:
-- MonoDevelop/Xamarin Studio has 'workspaces', which correspond to collections
-- of Premake workspaces. If premake supports multiple workspaces, we should
-- write out a workspace file...

	local p = premake
	local api = p.api


--
-- Register the D extension
--

	p.D = "D"

	api.addAllowed("language", p.D)
	api.addAllowed("debugger", "Mago")
	api.addAllowed("floatingpoint", "None")
	api.addAllowed("symbols", "LikeC")
	api.addAllowed("flags", {
		"CodeCoverage",
		"Documentation",
		"GenerateHeader",
		"GenerateDeps",
		"GenerateJSON",
		"GenerateMap",
		"Profile",
		"ProfileGC",
		"Quiet",
--		"Release",	// Note: We infer this flag from config.isDebugBuild()
		"RetainPaths",
		"UnitTest",
		"Verbose",
		"BetterC",
		"AddMainFunction",

		-- Deprecated
		"Deprecated", -- DEPRECATED
		"NoBoundsCheck", -- DEPRECATED
		"SeparateCompilation", -- DEPRECATED
		"SymbolsLikeC", -- DEPRECATED
	})


--
-- Register some D specific properties
--

	api.register {
		name = "compilationmodel",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"Package",
			"Project",
			"File"
		}
	}

	api.register {
		name = "importdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "stringimportdirs",
		scope = "config",
		kind = "list:directory",
		tokens = true,
	}

	api.register {
		name = "versionconstants",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "versionlevel",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "debugconstants",
		scope = "config",
		kind = "list:string",
		tokens = true,
	}

	api.register {
		name = "debuglevel",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "docdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "docname",
		scope = "config",
		kind = "file",
		tokens = true,
	}

	api.register {
		name = "headerdir",
		scope = "config",
		kind = "path",
		tokens = true,
	}

	api.register {
		name = "headername",
		scope = "config",
		kind = "file",
		tokens = true,
	}

	api.register {
		name = "depsfile",
		scope = "config",
		kind = "file",
		tokens = true,
	}

	api.register {
		name = "jsonfile",
		scope = "config",
		kind = "file",
		tokens = true,
	}

	api.register {
		name = "mincoverage",
		scope = "config",
		kind = "integer",
	}

	api.register {
		name = "boundschecking",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
			"SafeOnly"
		}
	}

	api.register {
		name = "deprecations",
		scope = "config",
		kind = "string",
		allowed = {
			"Default",
			"On",
			"Off",
			"Warn",
		}
	}


--
-- Deprecate some stuff
--
	api.deprecateValue("flags", "SymbolsLikeC", 'Use `symbols "LikeC"` instead',
	function(value)
		symbols "LikeC"
	end)
	api.deprecateValue("flags", "Deprecated", 'Use `deprecations "On"` instead',
	function(value)
		deprecations "On"
	end)
	api.deprecateValue("flags", "NoBoundsCheck", 'Use `boundschecking "Off"` instead',
	function(value)
		boundschecking "Off"
	end)
	api.deprecateValue("flags", "SeparateCompilation", 'Use `compilationmodel "File"` instead',
	function(value)
		compilationmodel "File"
	end)


--
-- Provide information for the help output
--
	newoption
	{
		trigger		= "dc",
		value		= "VALUE",
		description	= "Choose a D compiler",
		allowed = {
			{ "dmd", "Digital Mars (dmd)" },
			{ "gdc", "GNU GDC (gdc)" },
			{ "ldc", "LLVM LDC (ldc2)" },
		}
	}


--
-- Patch the project table to provide knowledge of D projects
--
	function p.project.isd(prj)
		return prj.language == p.D
	end


--
-- Patch the path table to provide knowledge of D file extenstions
--
	function path.isdfile(fname)
		return path.hasextension(fname, { ".d" })
	end

	function path.isdincludefile(fname)
		return path.hasextension(fname, { ".di" })
	end


--
-- Decide when to load the full module
--

	return function (cfg)
		local prj = cfg.project
		if p.project.iscpp(prj) then
			if cfg.project.hasdfiles == nil then
				cfg.project.hasdfiles = false
				-- scan for D files
				local tr = p.project.getsourcetree(prj)
				p.tree.traverse(tr, {
					onleaf = function(node)
						if not prj.hasdfiles then
							prj.hasdfiles = path.isdfile(node.name)
						end
					end
				})
			end
		end
		return (cfg.language == p.D or cfg.project.hasdfiles)
	end
