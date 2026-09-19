package wazero_raft

type Option func(*hostModule)

func WithStorageExtension(ext StorageExtension) Option {
	return func(h *hostModule) {
		h.extStorage = append(h.extStorage, ext)
	}
}

func WithStorageExtensionPersistent(ext StorageExtensionPersistent) Option {
	return func(h *hostModule) {
		h.extStoragePersistent = append(h.extStoragePersistent, ext)
	}
}
