package wazero_raft

type Option func(*hostModule)

func WithStorageExtension(ext ...StorageExtension) Option {
	return func(h *hostModule) {
		for _, e := range ext {
			h.extStorage = append(h.extStorage, e)
		}
	}
}

func WithStorageExtensionPersistent(ext ...StorageExtensionPersistent) Option {
	return func(h *hostModule) {
		for _, e := range ext {
			h.extStoragePersistent = append(h.extStoragePersistent, e)
		}
	}
}
