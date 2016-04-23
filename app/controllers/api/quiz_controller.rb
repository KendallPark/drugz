class Api::QuizController < ApiController
  def index
    data = YAML::load_file(Rails.root.join("config", "drugs.yml"))
    @quiz = Quiz.new(data, "Block 1").quiz
    render json: @quiz
  end

private

end
