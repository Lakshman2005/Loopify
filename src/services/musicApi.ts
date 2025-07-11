// Free music service using Jamendo API (completely free, no auth required)
interface JamendoTrack {
  id: string;
  name: string;
  duration: number;
  artist_name: string;
  album_name: string;
  album_image: string;
  audio: string;
  audiodownload: string;
}

interface JamendoResponse {
  results: JamendoTrack[];
}

export interface ApiTrack {
  id: string;
  title: string;
  artist: string;
  album: string;
  duration: number;
  cover: string;
  url: string;
  source: 'jamendo' | 'local';
}

class MusicApiService {
  private readonly JAMENDO_CLIENT_ID = 'b6747d04'; // Public demo client ID
  private readonly BASE_URL = 'https://api.jamendo.com/v3.0';

  // Get popular tracks
  async getPopularTracks(limit: number = 20): Promise<ApiTrack[]> {
    try {
      const response = await fetch(
        `${this.BASE_URL}/tracks/?client_id=${this.JAMENDO_CLIENT_ID}&format=json&limit=${limit}&order=popularity_total&include=licenses&groupby=artist_id&fuzzytags=electronic+pop+rock+indie`
      );
      
      if (!response.ok) {
        throw new Error('Failed to fetch tracks');
      }

      const data: JamendoResponse = await response.json();
      return data.results.map(this.transformTrack);
    } catch (error) {
      console.error('Error fetching popular tracks:', error);
      return [];
    }
  }

  // Search tracks
  async searchTracks(query: string, limit: number = 20): Promise<ApiTrack[]> {
    try {
      const response = await fetch(
        `${this.BASE_URL}/tracks/?client_id=${this.JAMENDO_CLIENT_ID}&format=json&limit=${limit}&search=${encodeURIComponent(query)}&include=licenses&groupby=artist_id`
      );
      
      if (!response.ok) {
        throw new Error('Failed to search tracks');
      }

      const data: JamendoResponse = await response.json();
      return data.results.map(this.transformTrack);
    } catch (error) {
      console.error('Error searching tracks:', error);
      return [];
    }
  }

  // Get tracks by genre
  async getTracksByGenre(genre: string, limit: number = 20): Promise<ApiTrack[]> {
    try {
      const response = await fetch(
        `${this.BASE_URL}/tracks/?client_id=${this.JAMENDO_CLIENT_ID}&format=json&limit=${limit}&fuzzytags=${encodeURIComponent(genre)}&include=licenses&groupby=artist_id&order=popularity_total`
      );
      
      if (!response.ok) {
        throw new Error('Failed to fetch tracks by genre');
      }

      const data: JamendoResponse = await response.json();
      return data.results.map(this.transformTrack);
    } catch (error) {
      console.error('Error fetching tracks by genre:', error);
      return [];
    }
  }

  // Get featured albums
  async getFeaturedAlbums(limit: number = 10) {
    try {
      const response = await fetch(
        `${this.BASE_URL}/albums/?client_id=${this.JAMENDO_CLIENT_ID}&format=json&limit=${limit}&order=popularity_total&include=tracks+licenses`
      );
      
      if (!response.ok) {
        throw new Error('Failed to fetch albums');
      }

      const data = await response.json();
      return data.results.map((album: any) => ({
        id: album.id,
        title: album.name,
        artist: album.artist_name,
        cover: album.image || 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
        year: new Date(album.releasedate).getFullYear(),
        trackCount: album.tracks?.length || 0,
        tracks: album.tracks?.map(this.transformTrack) || []
      }));
    } catch (error) {
      console.error('Error fetching albums:', error);
      return [];
    }
  }

  private transformTrack = (track: JamendoTrack): ApiTrack => ({
    id: track.id,
    title: track.name,
    artist: track.artist_name,
    album: track.album_name,
    duration: parseInt(track.duration.toString()),
    cover: track.album_image || 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop',
    url: track.audio,
    source: 'jamendo'
  });
}

export const musicApiService = new MusicApiService();