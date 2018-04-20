module VersionsHelper
  def diff_with_previous(version)
    changes = {}
    len = 0

    puts(HashDiff.diff(version.changeset['internal_name'].first, version.changeset['internal_name'].last).to_s) if version.changeset.key?('internal_name')

    version.changeset.each do |key, value|
      changes[key] = HashDiff.diff(JSON.parse(value.first), JSON.parse(value.last)) if key == 'runtime'
      changes[key] = HashDiff.diff(value.first, value.last) unless key == 'runtime'
      len += changes[key].size
      len += 1 if changes[key].empty?
    end

    [changes, len]
  end

  def change_to_html(key, change)
    case change.first
    when '~'
      if change[2]
        "<p class='alert alert-warning'><strong>#{key.upcase}:</strong> Changed <code>#{change[1]}</code> from <code>#{change[2] || 'nill'}</code> to <code>#{change[3]}</code></p>"
      else
        "<p class='alert alert-success'><strong>#{key.upcase}:</strong> Added <code>#{change[1]}</code> with value <code>#{change[3]}</code>"
      end
    when '-'
      "<p class='alert alert-danger'><strong>#{key.upcase}:</strong>  Removed <code>#{change[2]}</code> from <code>#{change[1]}</code>"
    when '+'
      "<p class='alert alert-success'><strong>#{key.upcase}:</strong> Added <code>#{change[1]}</code> with value <code>#{change[2]}</code>"
    end
  end
end
