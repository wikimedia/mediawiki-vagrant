require 'open-uri'

Puppet::Type.newtype(:tarball) do
    @doc = "Fetch and extract tarballed packages"

    ensurable

    newparam(:source) do
        desc "URL where the tarball will be found"
    end

    newparam(:path) do
        desc "Directory in which the tarball shall be extracted"
    end

    newparam(:creates) do
        desc "Will create this path when untarred"

        isnamevar
    end

    newparam(:storage) do
        desc "Directory in which to store the original tarball"
    end

    def create
        if not File.exists? filename
            fetch
        end
        extract
    end

    def creates_path
        self[:creates] || filename
    end

    def destroy
        File.unlink creates_path
    end

    def exists?
        # TODO verify signature
        File.exists? creates_path
    end

    def extract
        notice "Unpacking tarball #{filename} into #{self[:path]}"
        system("tar", "-C", self[:path], "-xzf", filename)
    end

    def fetch
        # TODO safe noclobber

        FileUtils.copy_stream(
            open(self[:source]),
            File.open(filename, "w+")
        )
    end

    def filename
        File.join(self[:storage], self[:source].split(/\//).last)
    end
end
