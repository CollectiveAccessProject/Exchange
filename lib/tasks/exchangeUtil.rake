require 'find'
require 'roo'

namespace :exchangeUtil do
  desc 'Import UMMA portfolios'
  task import_umma_portfolios: :environment do
    import_path = Rails.root.join("import", "portfolios")

    puts "Reading from " + import_path.to_s

    portfolios = {}
    data = {}
    log = {}

    Find.find(import_path) do |path|
      if FileTest.directory?(path)
        if File.basename(path)[0] == '.'
          Find.prune       # Don't look any further into this directory.
        else
          next
        end
      else
        p = Pathname.new(path.to_s)
        b = p.basename.to_s

        case
          when m = (/\~\$/.match(b))
            next
          when m = (/^(?<title>.*)[ ]*-[ ]*acc numbers/.match(b))
            portfolios[m[:title]] = {} if (!portfolios[m[:title]])
            portfolios[m[:title]]["acc"] = p.to_s
          when m= (/(?<title>.*)[ ]*-[ ]*data fields/.match(b))
            portfolios[m[:title]] = {} if (!portfolios[m[:title]])
            portfolios[m[:title]]["data"] = p.to_s
          else
            puts "Skipped " + b.to_s
        end


      end
    end

    # Accession #'s
    portfolios.each do |n, portfolio|
      begin
      puts portfolio
      acc = Roo::Excelx.new(portfolio["acc"])
      sheet = acc.sheet(0)

      data[n] = {} if !data[n]
      data[n][:acc] = [] if !data[n][:acc]

        sheet.each do |row|
          data[n][:acc].push(row[0])
        end

      rescue
        # noop
      end
    end


  # Portfolio data fields
  portfolios.each do |n, portfolio|
    begin
    acc = Roo::Excelx.new(portfolio["data"])
    sheet = acc.sheet(0)

    data[n] = {} if !data[n]
    data[n][:data] = {} if !data[n][:data]

    data[n][:data][:title] = sheet.cell(2,1).to_s.gsub("_", " ").capitalize
    data[n][:data][:text] = sheet.cell(2,2).to_s.gsub("_", " ")

    data[n][:data][:tags] = []
    data[n][:data][:collections] = []
    data[n][:data][:links] = []

    for r in 2 .. sheet.last_row
      data[n][:data][:tags].push(sheet.cell(r,3).to_s.gsub("_", " ")) if sheet.cell(r,3)
      data[n][:data][:collections].push(sheet.cell(r,4).to_s.gsub("_", " ")) if sheet.cell(r,4)

      data[n][:data][:links].push({name: sheet.cell(r,6).to_s.gsub("_", " "), url: sheet.cell(r,5)}) if sheet.cell(r,5)
    end
   rescue
      # noop
    end

  end

  data.each do |n, d|
    next if (!d || !d[:data] || !d[:data][:title])
    puts "CREATE PORTFOLIO " + d[:data][:title]
    r = Resource.where(title: d[:data][:title], resource_type: Resource::RESOURCE).first_or_create({
                                                                                                       user_id: 1,
                                                                                                       title: d[:data][:title],
                                                                                                       subtitle: '',
                                                                                                       body_text: d[:data][:text],
                                                                                                       resource_type: Resource::RESOURCE,
                                                                                                       copyright_license: 1,   # Creative Commons by-nc-sa
                                                                                                       copyright_notes: "University of Michigan Museum of Art",
                                                                                                       access: 1})
    r.save

    next if (!r.id)

    data[n][:acc].each do |a|
      if (c = Resource.where(collection_identifier: a.to_s).first)
        puts "ADD " + a.to_s
        next if (!r.id)
       # ResourceHierarchy.new({resource_id: r.id, child_resource_id: c.id}).save
        m = MediaFile.new({resource_id: r.id, caption: a.to_s, copyright_license: 1, copyright_notes: "", access: 1, title: a.to_s})
        m.save
        m.set_sourceable_media({collectionobject_link: {original_link: c.id.to_s}})
      end
    end

    data[n][:data][:tags].each do |a|
      puts "TAG " + a.to_s
      next if (!r.id)

      if (term = VocabularyTerm.where({term: a.to_s}).first)
        ResourcesVocabularyTerm.new({resource_id: r.id, vocabulary_term_id: term.id, user_id: 1, ip: "127.0.0.1"}).save
      else
        r.tags.where({taggable_id: r.id, taggable_type: 'Resource', tag: a.to_s}).first_or_create({tag: a.to_s, user_id: 1})
      end

    end

    data[n][:data][:links].each do |a|
      puts "LINK " + a[:url].to_s
      r.links.where({resource_id: r.id,  url: a[:url].to_s}).first_or_create({url: a[:url].to_s, caption: a[:name].to_s})
    end

    log[d[:data][:title].gsub("_", " ")] = r.id
  end


  # create cross-collection links
  data.each do |n, d|
    if (t=log[d[:data][:title]])
      if (r = Resource.where(title: t).first)
        log[d[:data][:collections]].each do |ct|
          if (c = Resource.where(title: ct).first)
            RelatedResource.new({resource_id: r.id, to_resource_id: c.id, caption: ""}).save
          end
        end
      end
    end
  end
end
end