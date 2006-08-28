class Referendum < Contest
  def validate
    errors.add :choices, 'only one choice per referendum' if choices.size > 1
  end

  def choice
    choices.first
  end
end
