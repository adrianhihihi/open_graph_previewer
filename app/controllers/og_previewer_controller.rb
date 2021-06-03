require 'faraday'
require 'ogp'

class OgPreviewerController < ApplicationController
  @@results = Array.new
  ProcessResult = Struct.new(:complete_dt, :time_consuming, :status, :image_url)

  def index
    if params.key?(:clear)
      @@results.clear
    end

    if params.key?(:submit_url) and params[:submit_url] != ""
      watcher_start = Time.now
      # og_url = 'https://ogp.me'
      og_url = params[:submit_url]

      begin
        response = Faraday.get(og_url)
        open_graph = OGP::OpenGraph.new(response.body)
        status = "Success"
      rescue Exception => e
        status = "Failed: " + e.message
      end

      watcher_stop = Time.now
      watcher_diff = watcher_stop - watcher_start

      @@results << ProcessResult.new(
        DateTime.now.to_s,
        watcher_diff.to_s + " s",
        status,
        open_graph != nil ? open_graph.image.url : ""
      )

      redirect_to action: "index"
    end

    @view_results = @@results.clone
  end

end
