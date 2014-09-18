#encoding: utf-8
module PaperclipCompression
  class Jpeg < Base

    JPEGOPTIM_DEFAULT_OPTS = '--max=90 --strip-all --preserve --totals –all-progressive'
    
    def initialize(file, options = {})
      super(file, options)

      @dst = Tempfile.new(@basename)
      @dst.binmode

      @src_path = File.expand_path(@file.path)
      @dst_path = File.expand_path(@dst.path)

      @cli_opts = init_cli_opts(:jpeg, default_opts)
    end

    def make
      begin
        if @cli_opts
          Paperclip.run(command_path('jpegoptim'), "#{@cli_opts} :src_path > :dst_path", src_path: @src_path, dst_path: @dst_path)
          @dst
        else
          @file
        end
      rescue Cocaine::ExitStatusError => e
        raise Paperclip::Error, "jpegoptim : There was an error processing the thumbnail for #{@basename}" if @whiny
      rescue Cocaine::CommandNotFoundError => e
        raise Paperclip::Errors::CommandNotFoundError.new("Could not run 'jpegoptim'. Please install jpegoptim.")
      end
    end

    private

    def default_opts
      JPEGOPTIM_DEFAULT_OPTS
    end

  end
end
