-- TestAdocLinks.lua - a test to verify that all external links in adoc files are functional
-- Copyright (C) 2014-2016 Zach Rhoads

-- This program is free software:  you can redistribute it and/or modify it
-- under the terms of  the  GNU General Public License  as published by the
-- Free Software Foundation, version 3 of the License.
--
-- This program  is  distributed  in the hope  that it will be useful,  but
-- WITHOUT  ANY WARRANTY;  without  even the implied warranty of MERCHANTA-
-- BILITY or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
-- License for more details.
--
-- You should have received a copy of the GNU General Public License  along
-- with this program. If not, see <http://www.gnu.org/licenses/>.

TestAdocLinks = {
	metadata = {
		description = "Verify that all external links in adoc files are functional",
		authors = "Zach Rhoads",
		changed = "2017-03-03",
		tags = {"AsciiDoc"}
	},
	requires = {"curl"},
	asciiObj = nil,
	main_file = nil,
  files = {},
  links = {},
  skipLinks = { },
  violations = { }
}


-- flattens tree to a map by doc name
function TestAdocLinks.walkContentTree(current)

  TestAdocLinks.files[current.file] = current.content

  if current.children then
    for key,value in pairs(current.children) do
      TestAdocLinks.walkContentTree(value)
    end
  end
end


-- finds links in each line of content in each file
-- matches both adoc-style links and md-style links
-- NOTE: all adoc-style links will match twice since they overlap with md-style links, but each link will only be tested once
function TestAdocLinks.findLinks()

  pattern = "link:https?://[%a%d%./_=%?%-#]*%["
  mdPattern =    "https?://[%a%d%./_=%?%-#]*%["
  
  for filename,content in pairs(TestAdocLinks.files) do
    for lineNum,lineContent in pairs(content) do
      for w in string.gmatch(lineContent, pattern) do
        -- strip out leading "link:" and trailing "["
        url = string.sub(w, 6, -2)
        if not TestAdocLinks.skipLinks[url] then
          TestAdocLinks.links[filename..":"..lineNum] = url
        end
      end
      
      for w in string.gmatch(lineContent, mdPattern) do
        -- strip out trainling "["
        url = string.sub(w, 0, -2)
        if not TestAdocLinks.skipLinks[url] then
          TestAdocLinks.links[filename..":"..lineNum] = url
        end
      end      
    end
  end
end


function TestAdocLinks.setUp()
  dofile(getScriptDirectory() .. "lib/asciidoc.lua")
  
  -- load skip links
  for line in io.lines("../asciidoctor-tests/skip-links.txt") do
    TestAdocLinks.skipLinks[line] = line
  end
  
  -- load style failures
  for line in io.lines("../asciidoctor-tests/violations.txt") do
    TestAdocLinks.violations[line] = line
  end
  
	TestAdocLinks.asciiObj = asciidoc.create(TestAdocLinks.main_file)

	if not TestAdocLinks.asciiObj then
		fail("Failed to create the AsciiDoc object. Ending now.")
	end
  
  for k,v in pairs(TestAdocLinks.asciiObj.tree) do
    TestAdocLinks.walkContentTree(v)
  end
  
  warn("Searching for links...")
  TestAdocLinks.allLinks = TestAdocLinks.findLinks()
end

function TestAdocLinks.testLinks()

  if table.isEmpty(TestAdocLinks.links) then
    pass("No links found.")
    return
  end

  for location,link in pairs(TestAdocLinks.links) do
    command =  [[ checkLink() {
       curl -4ILks --post302 --connect-timeout 20 --retry 2 --max-time 20 -A 'Mozilla/5.0 (X11; Linux x86_64; rv:31.0) Gecko/20100101 Firefox/31.0' $1 > /dev/null
       echo "$1______$?"
      }
     export -f checkLink
     echo -e ']] .. link .. [[' | xargs -d'\n' -n1 -P0 -I url bash -c 'echo `checkLink url`' ]]
     output = execCaptureOutputAsTable(command)
     
     for _, line in ipairs(output) do
      link, exitCode = line:match("(.+)______(%d+)$")
      if exitCode == "0" then
        pass(link)
      else
        fail(link .. " at " .. location)
      end
    end
  end
end

-- This test will check for style violations
function TestAdocLinks.testStyle()

  if table.isEmpty(TestAdocLinks.files) then
      warn("No content found.")
      return
  end

  for filename,content in pairs(TestAdocLinks.files) do
    for lineNum,lineContent in pairs(content) do
      for number,violation in pairs(TestAdocLinks.violations) do
        if string.match(lineContent, violation) then
          fail("Violation: " .. violation .. " found at " .. filename .. ":" .. lineNum)
        end
      end
    end
    
  end
end

