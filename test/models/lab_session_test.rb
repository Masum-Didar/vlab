require "test_helper"

class LabSessionTest < ActiveSupport::TestCase
  test "tracks pipette tip lifecycle" do
    session = LabSession.create!(
      user: User.create!(email: "pipette-student@example.com", password: "password123", role: :student),
      experiment: Experiment.create!(title: "Pipette lifecycle", published: true)
    )

    assert_equal false, session.pipette_status["has_tip"]
    assert_equal 0, session.pipette_status["tip_generation"]

    session.attach_pipette_tip!
    assert_equal true, session.reload.pipette_status["has_tip"]
    assert_equal 1, session.pipette_status["tip_generation"]

    session.record_pipette_transfer!(source: "DNA Ladder Tube", target: "Gel Well 1")
    assert_equal "DNA Ladder Tube", session.reload.pipette_status["last_transfer_source"]
    assert_equal 1, session.pipette_status["last_transfer_tip_generation"]

    session.eject_pipette_tip!
    assert_equal false, session.reload.pipette_status["has_tip"]
    assert_equal 1, session.pipette_status["ejected_count"]
  end
end
