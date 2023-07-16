UBLUE_ROOT := output
TARGET := ublue-update
SOURCE_DIR := $(UBLUE_ROOT)/$(TARGET)
RPMBUILD := $(UBLUE_ROOT)/rpmbuild

all: build

build:
	flake8 src
	black --check src
	python3 -m build

spec: output
	rpkg spec --outdir $(PWD)/output
build-rpm:
	rpkg local --outdir $(PWD)/output
output:
	mkdir -p output

# Phony targets - utilities and helpers
.PHONY: format
format:
	black src

.PHONY: dnf-install
dnf-install:
	dnf install -y output/noarch/*.rpm

.PHONY: builder-image
builder-image:
	podman build -t $(TARGET):builder --target builder .

.PHONY: builder-exec
builder-exec:
	podman run --rm -it \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		-e DISPLAY \
		-e DBUS_SESSION_BUS_ADDRESS \
		-e XDG_RUNTIME_DIR \
		--ipc host \
		-v "/tmp/.X11-unix:/tmp/.X11-unix" \
		-v /var/run/dbus:/var/run/dbus \
		-v /run/user/1000/bus:/run/user/1000/bus \
		-v /run/dbus:/run/dbus \
		-v "${XDG_RUNTIME_DIR}:${XDG_RUNTIME_DIR}" \
		--security-opt label=disable \
		$(TARGET):builder

.PHONY: clean
clean:
	rm -rf $(UBLUE_ROOT)
