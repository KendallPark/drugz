class Quiz
  attr_reader :quiz
  def initialize(data, block)
    key = data[block]["key"] - ["Case", "Drug", "Pregnancy Category"]
    drugs = data[block]["drugs"]

    sections = drugs.keys.shuffle

    stuff = Hash[key.collect { |item| [item, []] }]
    drugs.each do |drug_name, drug|
      key.each do |attribute|
        stuff[attribute].push drug[attribute] if drug[attribute]
      end
    end

    @quiz = []
    sections.each do |section|
      sec = {title: section, questions: []}
      key.each do |attribute|
        if drugs[section][attribute]
          options = stuff[attribute].sample(5)
          unless options.include? drugs[section][attribute]
            options.pop
            options.push drugs[section][attribute]
          end
          options.shuffle!
          question = {
            question: "#{attribute.humanize}?",
            options: options,
            answer: options.index(drugs[section][attribute])
          }
          sec[:questions].push question
        end
      end
      next if sec[:questions].length < 1
      # sec[:questions].shuffle!
      @quiz.push sec
    end
  end
end
