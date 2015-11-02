require "spec_helper"

class StYunosAppCenterCnt < Phoenix::Base
end

describe Phoenix do
  context "Rjb" do

    context "execute sql" do
      let(:sql) {
        "select * from ST_YUNOS_APP_CENTER_CNT limit 2"
      }

      it {
        rs = Phoenix::Rjb.execute(sql)
        expect(rs.size).to eq(2)
      }
    end

    context "all" do
      it {
        expect(StYunosAppCenterCnt.all.size).to_not eq(0)
      }
    end

    context "first" do
      it {
        expect(StYunosAppCenterCnt.first).to_not be_nil
      }
    end

    context "get one field value" do
      it {
        o = StYunosAppCenterCnt.first
        expect(o.CLIENT_VERSION).to_not be_empty
      }
    end

  end
end
