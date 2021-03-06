# This file is autogenerated. Do not edit it by hand. Regenerate it with:
#   srb rbi gems

# typed: strict
#
# If you would like to make changes to this file, great! Please create the gem's shim here:
#
#   https://github.com/sorbet/sorbet-typed/new/master?filename=lib/sneakers/all/sneakers.rbi
#
# sneakers-2.11.0

module Sneakers
  def clear!; end
  def configure(opts = nil); end
  def configure_server; end
  def configured?; end
  def daemonize!(loglevel = nil); end
  def error_reporters; end
  def logger; end
  def logger=(logger); end
  def publish(msg, routing); end
  def server=(server); end
  def server?; end
  def setup_general_logger!; end
  def setup_general_publisher!; end
  def setup_worker_concerns!; end
  extend Sneakers
end
module Sneakers::ErrorReporter
  def worker_error(exception, context_hash = nil); end
end
class Sneakers::ErrorReporter::DefaultLogger
  def call(exception, worker, context_hash); end
end
class Sneakers::Configuration
  def ==(*args, &block); end
  def [](*args, &block); end
  def []=(*args, &block); end
  def clear; end
  def deep_merge(first, second); end
  def delete(*args, &block); end
  def fetch(*args, &block); end
  def has_key?(*args, &block); end
  def initialize; end
  def inspect; end
  def inspect_with_redaction; end
  def inspect_without_redaction; end
  def map_all_deprecated_options(hash); end
  def map_deprecated_options_key(target_key, deprecated_key, key, delete_deprecated_key, hash = nil); end
  def merge!(hash); end
  def merge(hash); end
  def to_hash(*args, &block); end
  extend Forwardable
end
module Sneakers::Support
end
class Sneakers::Support::ProductionFormatter < Logger::Formatter
  def self.call(severity, time, program_name, message); end
end
module Sneakers::Concerns
end
module Sneakers::Concerns::Logging
  def self.included(base); end
end
module Sneakers::Concerns::Logging::ClassMethods
  def configure_logger(log = nil); end
  def logger; end
  def logger=(logger); end
end
module Sneakers::Metrics
end
class Sneakers::Metrics::NullMetrics
  def increment(metric); end
  def timing(metric, &block); end
end
module Sneakers::Concerns::Metrics
  def self.included(base); end
end
module Sneakers::Concerns::Metrics::ClassMethods
  def configure_metrics(metrics = nil); end
  def metrics; end
  def metrics=(metrics); end
end
module Sneakers::Handlers
end
class Sneakers::Handlers::Oneshot
  def acknowledge(hdr, props, msg); end
  def error(hdr, props, msg, err); end
  def initialize(channel, queue, opts); end
  def noop(hdr, props, msg); end
  def reject(hdr, props, msg, requeue = nil); end
end
class Sneakers::ContentType
  def deserializer; end
  def initialize(serializer, deserializer); end
  def self.deserialize(payload, content_type); end
  def self.passthrough; end
  def self.register(content_type: nil, serializer: nil, deserializer: nil); end
  def self.reset!; end
  def self.serialize(payload, content_type); end
  def serializer; end
end
class Sneakers::Queue
  def channel; end
  def create_bunny_connection; end
  def exchange; end
  def initialize(name, opts); end
  def name; end
  def opts; end
  def subscribe(worker); end
  def unsubscribe; end
end
class Sneakers::Utils
  def self.make_worker_id(namespace); end
  def self.parse_workers(workerstring); end
end
module Sneakers::Worker
  def ack!; end
  def do_work(delivery_info, metadata, msg, handler); end
  def id; end
  def initialize(queue = nil, pool = nil, opts = nil); end
  def log_msg(msg); end
  def logger; end
  def metrics; end
  def opts; end
  def process_work(delivery_info, metadata, msg, handler); end
  def publish(msg, opts); end
  def queue; end
  def reject!; end
  def requeue!; end
  def run; end
  def self.included(base); end
  def stop; end
  def worker_trace(msg); end
  extend Sneakers::Concerns::Logging::ClassMethods
  extend Sneakers::Concerns::Metrics::ClassMethods
  include Sneakers::Concerns::Logging
  include Sneakers::Concerns::Metrics
  include Sneakers::ErrorReporter
end
module Sneakers::Worker::ClassMethods
  def enqueue(msg, opts = nil); end
  def from_queue(q, opts = nil); end
  def publisher; end
  def queue_name; end
  def queue_opts; end
end
class Sneakers::Publisher
  def channel; end
  def connect!; end
  def connected?; end
  def create_bunny_connection; end
  def ensure_connection!; end
  def exchange; end
  def initialize(opts = nil); end
  def publish(msg, options = nil); end
end
