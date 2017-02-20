class QuestionsController < ApplicationController

  before_action :authorize!, only: [:flag, :create, :update]

  def create
    question = Question.new(permitted_params)
    if question.valid?
      question.save
      render json: { question: question }, status: 201
    else
      render json: { errors: question.errors.full_messages }, status: 400
    end
  end

  def update
    question = Question.find(params[:id])
    question.update(permitted_params)

    if question.valid?
      question.save
      render json: { question: question }, status: 200
    else
      render json: { errors: question.errors.full_messages }, status: 400
    end
  end

  def flag
    question = Question.find(params[:question_id])
    question.increment!(:flag_count)
    render json: { message: "Question successfully flagged!" }, status: 200
  end

  private

  def permitted_params
    params.require(:question)
          .permit(
            :id,
            :event,
            :episode_id,
          )
  end
end
