# frozen_string_literal: true

require "rails_helper"

RSpec.describe Submission do
  subject(:submission) { described_class.create(params) }

  let(:params) do
    {
      use_case: "one",
      first_name: "Langley",
      last_name: "Yorke",
      nino: "MN212451D",
      dob: "1992-07-22",
      start_date: "2020-08-01",
      end_date: "2020-10-01",
    }
  end

  it {
    expect(submission).to validate_inclusion_of(:use_case).in_array(%w[one two three four]).with_message(/Invalid use case/)
  }

  describe ".as_json" do
    subject(:as_json) { submission.as_json }

    it "returns the expected values" do
      expect(as_json.keys).to match_array %w[use_case first_name last_name nino dob start_date end_date]
    end

    it "does not include standard model values" do
      expect(as_json.keys).not_to include %w[id status created_at updated_at]
    end
  end

  describe "#save" do
    context "with first name missing" do
      before { params.delete(:first_name) }

      it "does not persist model" do
        expect { submission.save }.not_to(change(described_class, :count))
      end

      it "raises an error" do
        expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
        expect(submission.errors.full_messages).to include("First name can't be blank")
      end
    end

    context "with last name errors" do
      context "with last name missing" do
        before { params.delete(:last_name) }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Last name can't be blank")
        end
      end

      context "with last name containing a number" do
        before { params[:last_name] = "Yorke1" }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Last name can't contain a number")
        end
      end
    end

    context "with nino errors" do
      context "with nino missing" do
        before { params.delete(:nino) }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Nino is not valid")
        end
      end

      context "with an invalid nino" do
        before { params[:nino] = "invalid_nino" }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Nino is not valid")
        end
      end
    end

    context "with dob errors" do
      context "with dob missing" do
        before { params.delete(:dob) }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Dob is not a valid date")
        end
      end

      context "with a badly formatted dob" do
        before { params[:dob] = "date" }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Dob is not a valid date")
        end
      end

      context "with a dob in the future" do
        before { params[:dob] = Time.zone.today + 1 }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Dob is not a valid date")
        end
      end
    end

    context "with start_date errors" do
      context "with start_date missing" do
        before { params.delete(:start_date) }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Start date is not a valid date")
        end
      end

      context "with a badly formatted start_date" do
        before { params[:start_date] = "date" }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Start date is not a valid date")
        end
      end

      context "with a start_date in the future" do
        before { params[:start_date] = Time.zone.today + 1 }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Start date is not a valid date")
        end
      end
    end

    context "with end_date errors" do
      context "with end_date missing" do
        before { params.delete(:end_date) }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("End date is not a valid date")
        end
      end

      context "with a badly formatted end_date" do
        before { params[:end_date] = "date" }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("End date is not a valid date")
        end
      end

      context "with an end_date in the future" do
        before { params[:end_date] = Time.zone.today + 1 }

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("End date is not a valid date")
        end
      end

      context "with an end_date before the start_date" do
        before do
          params[:start_date] = Time.zone.today - 9
          params[:end_date] = Time.zone.today - 10
        end

        it "does not persist model" do
          expect { submission.save }.not_to(change(described_class, :count))
        end

        it "raises an error" do
          expect { submission.save! }.to raise_error(ActiveRecord::RecordInvalid)
          expect(submission.errors.full_messages).to include("Start date is not a valid date",
                                                             "End date is not a valid date")
        end
      end
    end
  end

  context "with oauth_application" do
    let(:params) do
      {
        use_case: "one",
        first_name: "Langley",
        last_name: "Yorke",
        nino: "MN212451D",
        dob: "1992-07-22",
        start_date: "2020-08-01",
        end_date: "2020-10-01",
        oauth_application_id: oauth_application.id,
      }
    end

    let(:oauth_application) { create(:oauth_application) }

    it "nullifies oauth_application_id when it is destroyed" do
      expect { oauth_application.destroy }.to change { submission.reload.oauth_application_id }.from(a_kind_of(String)).to(nil)
    end
  end
end
