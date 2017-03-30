##### AYTYCRM - Silvio Fernandes #####
module AytyDashboardsHelper

  def ayty_format_title_for_versions(fixed_version_name, release_geral_int, release_colab_int)
    title = ""

    if release_geral_int
      if release_geral_int.to_s.length > 0
        title += "Release Geral - Interno: #{release_geral_int.to_s}"
      end
    end

    if release_colab_int
      if release_colab_int.to_s.length > 0
        title += "\n" if title.length > 0
        title += "Release Colab - Interno: #{release_colab_int.to_s}"
      end
    end

    if fixed_version_name
      if fixed_version_name.to_s.length > 0
        title += "\n" if title.length > 0
        title += "#{l(:field_fixed_version)}: #{fixed_version_name.to_s}"
      end
    end

    return title
  end

end
