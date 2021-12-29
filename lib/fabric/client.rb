# frozen_string_literal: true

module Fabric
  #
  # Gateway Client represents the connection to a Hyperledger Fabric Gateway.
  #
  class Client
    attr_reader :grpc_client, :default_call_options

    #
    # Initializes a client
    #
    # @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:initialize
    #
    # @param [Gateway::Gateway::Stub] grpc_client grpc gateway client stub
    # @param [string] host hostname and port of the gateway
    # @param [GRPC::Core::ChannelCredentials|GRPC::Core::XdsChannelCredentials|Symbol] creds channel credentials
    #                                                                                  (usually the CA certificate)
    # @param [Hash] default_call_options call options to use by default for different operations
    # @option default_call_options [Hash] :endorse_options default options for endorse call; @see keyword arguments in https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    # @option default_call_options [Hash] :evaluate_options default options for evaluate call; @see keyword arguments in
    #                                              https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    # @option default_call_options [Hash] :submit_options default options for submit call; @see keyword arguments in https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    # @option default_call_options [Hash] :commit_status_options default options for commit_status call;
    #                                     @see keyword arguments in https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    # @option default_call_options [Hash] :chaincode_events_options default options for chaincode_events call;
    #                                     @see keyword arguments in https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    # @param [Hash] **client_opts client initialization options; @see keyword arguments at https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:initialize
    #
    def initialize(grpc_client: nil, host: nil, creds: nil, default_call_options: {}, **client_opts)
      if grpc_client
        init_stub grpc_client
      elsif host && creds
        init_grpc_args(host, creds, **client_opts)
      else
        raise InvalidArgument, 'Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>'
      end
      init_call_options(default_call_options)
    end

    #
    # Submits an evaluate_request to the gateway to be evaluted.
    #
    # @param [Gateway::EvaluateRequest] evaluate_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Gateway::EvaluateResponse] evaluate_response
    #
    def evaluate(evaluate_request, options = {})
      @grpc_client.evaluate(evaluate_request, @default_call_options[:evaluate_options].merge(options))
    end

    #
    # Submits an endorse_request to the gateway to be evaluted.
    #
    # @param [Gateway::EndorseRequest] endorse_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Gateway::EndorseResponse] endorse_response
    #
    def endorse(endorse_request, options = {})
      @grpc_client.endorse(endorse_request, @default_call_options[:endorse_options].merge(options))
    end

    #
    # Submits an submit_request to the gateway to be evaluted.
    #
    # @param [Gateway::SubmitRequest] submit_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Gateway::SubmitResponse] submit_response
    #
    def submit(submit_request, options = {})
      @grpc_client.submit(submit_request, @default_call_options[:submit_options].merge(options))
    end

    #
    # Submits an commit_status_request to the gateway to be evaluted.
    #
    # @param [Gateway::CommitStatusRequest] commit_status_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:request_response
    #
    # @return [Gateway::CommitStatusResponse] commit_status_response
    #
    def commit_status(commit_status_request, options = {})
      @grpc_client.commit_status(commit_status_request, @default_call_options[:commit_status_options].merge(options))
    end

    #
    # Subscribe to chaincode events
    #
    # @NOTE: This function has never been utilized or tested. This function is probably wrong, missing a block.
    # @TODO: add testing!
    #
    # @param [Gateway::ChaincodeEventsRequest] chaincode_events_request
    # @param [Hash] options gRPC call options (merged with default options) @see https://www.rubydoc.info/gems/grpc/GRPC%2FClientStub:server_streamer
    #
    # @return [Gateway::ChaincodeEventsResponse] commit_status_response (probably wrong, this is a stream.)
    #
    def chaincode_events(chaincode_events_request, options = {}, &block)
      @grpc_client.chaincode_events(chaincode_events_request,
                                    @default_call_options[:chaincode_events_options].merge(options), &block)
    end

    private

    def init_stub(stub)
      unless stub.is_a? ::Gateway::Gateway::Stub
        raise InvalidArgument, 'Must pass a Gateway::Gateway::Stub or <host>, <creds>, <client_opts>'
      end

      @grpc_client = stub
    end

    def init_grpc_args(host, creds, **client_opts)
      unless creds.is_a?(GRPC::Core::ChannelCredentials) ||
             creds.is_a?(GRPC::Core::XdsChannelCredentials) ||
             creds.is_a?(Symbol)
        raise InvalidArgument, 'creds is not a ChannelCredentials, XdsChannelCredentials, or Symbol'
      end

      @grpc_client = ::Gateway::Gateway::Stub.new(host, creds, **client_opts)
    end

    def init_call_options(call_options)
      @default_call_options = call_options
      @default_call_options[:endorse_options] ||= {}
      @default_call_options[:evaluate_options] ||= {}
      @default_call_options[:submit_options] ||= {}
      @default_call_options[:commit_status_options] ||= {}
      @default_call_options[:chaincode_events_options] ||= {}
    end
  end
end