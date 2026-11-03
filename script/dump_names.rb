# Dumps everything the gem returns for a list of names so that two builds can
# be compared with `diff`. Uses only the public API shared by every version.
#
# Input (stdin): one name per line, optionally followed by a tab and a slug or
# email localpart to check with `matches_slug_or_localpart`.
#
#   ruby -Ilib script/dump_names.rb < names.tsv > before.txt
#   (switch gem version)
#   ruby -Ilib script/dump_names.rb < names.tsv > after.txt
#   diff before.txt after.txt

require 'humanname'

MAX_GROUP_SIZE = 50

parsed = []

$stdin.each_line do |line|
  raw, slug = line.chomp.split("\t", 2)
  next if raw.nil? || raw.empty?

  name = HumanName.parse(raw)
  if name.nil?
    puts "#{raw.inspect}\tnil"
    next
  end

  fields = HumanName::NAME_PARTS.map { |part| "#{part}=#{name.send(part).inspect}" }
  fields << "hash=#{name.hash}"
  fields << "goes_by_middle_name=#{name.goes_by_middle_name}"
  fields << "length=#{name.length}"
  fields << "slug(#{slug.inspect})=#{name.matches_slug_or_localpart(slug)}" if slug && !slug.empty?
  puts "#{raw.inspect}\t#{fields.join("\t")}"

  parsed << [raw, name]
end

# `==` is only consulted for names that share a hash (see HumanName.from_strings
# in academia-app), so compare pairs within each hash group.
parsed.group_by { |_, name| name.hash }.each_value do |group|
  group = group.first(MAX_GROUP_SIZE)
  group.combination(2) do |(raw_a, a), (raw_b, b)|
    puts "eq\t#{raw_a.inspect}\t#{raw_b.inspect}\t#{a == b}"
  end
end
