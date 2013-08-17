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
module Jekyll::Convertible
    alias_method :orig_read_yaml, :read_yaml 
    def read_yaml(base, name)
		if File.extname(name) == ".md"
			STDERR.write "Processing #{name}\n"
            path = File.join(base, name)
            text = File.read(path)
            first_header = text.split("\n").select do |line|
                line[0] == "#"
            end.first
            converted = text.gsub(/\(.*\.md\)/) do |match|
                inner = match[1...-1]
                link = (name == "index.md" ? inner : File.join("..", inner)).gsub(".md", "")
                "(#{link})"
            end
            self.content = converted
            self.data = {
                "title" => (first_header || "").gsub(/^#+ /, ""),
                "layout" => "default"
            }
		else
			orig_read_yaml(base, name)
		end
    end
end
