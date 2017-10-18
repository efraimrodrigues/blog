# Setup

	stack setup
	stack install # will install a `blog` executable in ~/.local/bin

# Build

	stack init
	stack build

# Preview
	stack exec blog build
	stack exec blog watch

# Create a new article

	make new
