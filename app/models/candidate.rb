class Candidate < Contest
  def validate
    errors.add :name, 'need at least two candidates' if Guide::C3 == self.guide.legal && self.choices.size < 2
  end
end
