require "crochet"

# Allow posts names to not begin with a date
STRICT_MATCH = Jekyll::Post::MATCHER
Jekyll::Post::MATCHER = /^(.+\/)*(\d+-\d+-\d+)?-?(.*)(\.[^.]+)$/

# If a post name doesn't begin with a date,
# pretend the date is the last time the file
# was modified.
Crochet::Hook.new(Jekyll::Post) do
	before! :process do |name|
		if not name =~ STRICT_MATCH
			mtime = File.mtime(File.join(@base, name))
			split = File.split(name)
			name = File.join(split[0], "#{mtime.strftime("%Y-%m-%d")}-#{split[1]}")
		end
		name
	end
end

# Intercept .md files, and generate metadata
Crochet::Hook.new(File) do
	after! :read, :class do |result, path|
		if File.extname(path) == ".md"
			STDERR.write "Processing #{path}\n"
            first_header = result.split("\n").select do |line|
                line[0] == "#"
            end.first
            meta = {
                "title" => (first_header || "").gsub(/^#+ /, ""),
                "layout" => "default"
            }
            converted = result.gsub(/\(.*\.md\)/) do |match|
                inner = match[1...-1]
                link = File.join("..", inner).gsub(".md", "")
                "(#{link})"
            end
			YAML.dump(meta) + "---\n" + converted
		else
			result
		end
	end
end
