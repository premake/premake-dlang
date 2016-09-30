--
-- d/d.lua
-- Define the D makefile action(s).
-- Copyright (c) 2013-2015 Andrew Gough, Manu Evans, and the Premake project
--

	local p = premake

	p.modules.d = {}

	local m = p.modules.d

	m._VERSION = p._VERSION
	m.elements = {}

	local api = p.api


--
-- Patch actions
--
	include( "tools/dmd.lua" )
	include( "tools/gdc.lua" )
	include( "tools/ldc.lua" )

	include( "actions/gmake.lua" )
	include( "actions/vstudio.lua" )
	-- this one depends on the monodevelop extension
	if p.modules.monodevelop then
		include( "actions/monodev.lua" )
	end

	return m
