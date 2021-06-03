require 'faraday'
require 'ogp'

class OgPreviewerController < ApplicationController
  ProcessResult = Struct.new(:complete_dt, :time_consuming, :status, :image_url)
  @@results = Array.new
  @@results_mutex = Mutex.new

  def index
    if params.key?(:clear)
      # Lock the mutex corresponding to results
      # to prevent other threads from accessing it
      @@results_mutex.synchronize do
        # Clear history
        @@results.clear
      end
    end

    if params.key?(:submit_url) and params[:submit_url] != ""
      # Asynchronous processing in a new thread
      Thread.new do
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

        # Calculate processing time
        watcher_diff = watcher_stop - watcher_start

        @@results_mutex.synchronize do
          # Add the processing results to the @@results queue
          @@results << ProcessResult.new(
            DateTime.now.to_s,
            watcher_diff.to_s + " s",
            status,
            open_graph != nil ? open_graph.image.url : ""
          )
        end
      end

      redirect_to action: "index"
    end

    @@results_mutex.synchronize do
      # Clone the array to avoid potential data race
      @view_results = @@results.clone
    end
  end

end
