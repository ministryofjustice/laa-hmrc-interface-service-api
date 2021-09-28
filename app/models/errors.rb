module Errors
  class ContractError < StandardError; end

  class CitizenDetailsMismatchError < StandardError; end

  class SentryIgnoresThisSidekiqFailError < StandardError; end
end
