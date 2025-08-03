import axios from 'axios';
import React, { useEffect, useState } from 'react'

const ImageList = () => {
    const [images, setImages] = useState([]);
  
    useEffect(() => {
      axios.get(`${import.meta.env.VITE_BACKEND_ENDPOINT}/api/images`)
        .then(response => setImages(response.data.images))
        .catch(error => console.error('Error fetching todos:', error));
    }, []);

    console.log(images)
  return (
    <div className="title-banner py-4">
      <div className="container">
        <div className="row">
        <h4>Images</h4>
        </div>
      </div>
        
        <div className="img-grid">
            {Array.isArray(images) && images.map(image => (
              <img key={image} src={image}/>
            ))}
        </div>
    </div>
  )
}

export default ImageList