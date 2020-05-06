// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

// MARK: - Welcome
struct Welcome: Codable {
	let data: [Datum]
	let pagination: Pagination
	let meta: Meta
}

// MARK: - Datum
struct Datum: Codable {
	let type: TypeEnum
	let id: String
	let url: String
	let slug: String
	let bitlyGIFURL, bitlyURL, embedURL: String
	let username: String
	let source: String
	let title: String
	let rating: Rating
	let contentURL: String
	let sourceTLD: String
	let sourcePostURL: String
	let isSticker: Int
	let importDatetime, trendingDatetime: String
	let images: Images
	let analyticsResponsePayload: String
	let analytics: Analytics
	let user: User?
	
	enum CodingKeys: String, CodingKey {
		case type, id, url, slug
		case bitlyGIFURL = "bitly_gif_url"
		case bitlyURL = "bitly_url"
		case embedURL = "embed_url"
		case username, source, title, rating
		case contentURL = "content_url"
		case sourceTLD = "source_tld"
		case sourcePostURL = "source_post_url"
		case isSticker = "is_sticker"
		case importDatetime = "import_datetime"
		case trendingDatetime = "trending_datetime"
		case images
		case analyticsResponsePayload = "analytics_response_payload"
		case analytics, user
	}
}

// MARK: - Analytics
struct Analytics: Codable {
	let onload, onclick, onsent: Onclick
}

// MARK: - Onclick
struct Onclick: Codable {
	let url: String
}

// MARK: - Images
struct Images: Codable {
	let downsizedLarge, fixedHeightSmallStill: The480_WStill
	let original, fixedHeightDownsampled: FixedHeight
	let downsizedStill, previewWebp, fixedHeightStill, downsizedMedium: The480_WStill
	let downsized: The480_WStill
	let originalMp4: DownsizedSmall
	let fixedHeightSmall, fixedHeight, fixedWidthSmall: FixedHeight
	let downsizedSmall, preview: DownsizedSmall
	let fixedWidthDownsampled: FixedHeight
	let fixedWidthSmallStill, the480WStill, originalStill, fixedWidthStill: The480_WStill
	let looping: Looping
	let fixedWidth: FixedHeight
	let previewGIF: The480_WStill
	
	enum CodingKeys: String, CodingKey {
		case downsizedLarge = "downsized_large"
		case fixedHeightSmallStill = "fixed_height_small_still"
		case original
		case fixedHeightDownsampled = "fixed_height_downsampled"
		case downsizedStill = "downsized_still"
		case previewWebp = "preview_webp"
		case fixedHeightStill = "fixed_height_still"
		case downsizedMedium = "downsized_medium"
		case downsized
		case originalMp4 = "original_mp4"
		case fixedHeightSmall = "fixed_height_small"
		case fixedHeight = "fixed_height"
		case fixedWidthSmall = "fixed_width_small"
		case downsizedSmall = "downsized_small"
		case preview
		case fixedWidthDownsampled = "fixed_width_downsampled"
		case fixedWidthSmallStill = "fixed_width_small_still"
		case the480WStill = "480w_still"
		case originalStill = "original_still"
		case fixedWidthStill = "fixed_width_still"
		case looping
		case fixedWidth = "fixed_width"
		case previewGIF = "preview_gif"
	}
}

// MARK: - The480_WStill
struct The480_WStill: Codable {
	let height: String
	let size: String?
	let url: String
	let width: String
}

// MARK: - DownsizedSmall
struct DownsizedSmall: Codable {
	let height: String
	let mp4: String
	let mp4Size, width: String
	
	enum CodingKeys: String, CodingKey {
		case height, mp4
		case mp4Size = "mp4_size"
		case width
	}
}

// MARK: - FixedHeight
struct FixedHeight: Codable {
	let height: String
	let mp4: String?
	let mp4Size: String?
	let size: String
	let url: String
	let webp: String
	let webpSize, width: String
	let frames, hash: String?
	
	enum CodingKeys: String, CodingKey {
		case height, mp4
		case mp4Size = "mp4_size"
		case size, url, webp
		case webpSize = "webp_size"
		case width, frames, hash
	}
}

// MARK: - Looping
struct Looping: Codable {
	let mp4: String
	let mp4Size: String
	
	enum CodingKeys: String, CodingKey {
		case mp4
		case mp4Size = "mp4_size"
	}
}

enum Rating: String, Codable {
	case g = "g"
	case pg = "pg"
	case pg13 = "pg-13"
}

enum TypeEnum: String, Codable {
	case gif = "gif"
}

// MARK: - User
struct User: Codable {
	let avatarURL: String
	let bannerImage, bannerURL: String
	let profileURL: String
	let username, displayName: String
	let isVerified: Bool
	
	enum CodingKeys: String, CodingKey {
		case avatarURL = "avatar_url"
		case bannerImage = "banner_image"
		case bannerURL = "banner_url"
		case profileURL = "profile_url"
		case username
		case displayName = "display_name"
		case isVerified = "is_verified"
	}
}

// MARK: - Meta
struct Meta: Codable {
	let status: Int
	let msg, responseID: String
	
	enum CodingKeys: String, CodingKey {
		case status, msg
		case responseID = "response_id"
	}
}

// MARK: - Pagination
struct Pagination: Codable {
	let totalCount, count, offset: Int
	
	enum CodingKeys: String, CodingKey {
		case totalCount = "total_count"
		case count, offset
	}
}
