class EmberIndexController < ApplicationController
  before_action :set_response_format

  SHORT_UUID_V4_REGEXP = /\A[0-9a-f]{7}\z/i

  def index
    index_key = if Rails.env.development?
                  'fieldthebern-ember:index:__development__'
                elsif fetch_revision
                  "fieldthebern-ember:index:#{fetch_revision}"
                else
                  Sidekiq.redis { |r| "fieldthebern-ember:index:#{r.get('fieldthebern-ember:index:current')}" }
                end
    index = Sidekiq.redis { |r| r.get(index_key) }
    render text: process_index(index).html_safe, layout: false
  end

  private

  def fetch_revision
    rev = params[:revision]
    if rev =~ SHORT_UUID_V4_REGEXP
      rev
    end
  end

  def process_index(index)
    return "INDEX NOT FOUND" unless index

    index.sub!('/ember-cli-live-reload', 'http://localhost:4200/ember-cli-live-reload') if Rails.env.development?

    index
  end

  def set_response_format
    request.format = :html
  end
end
