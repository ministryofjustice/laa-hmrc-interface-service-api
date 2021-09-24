module Errors
  class ContractError < StandardError; end

  class ClientDetailsMismatchError < StandardError; end

  class SentryIgnoresThisSidekiqFailError < StandardError; end
end
